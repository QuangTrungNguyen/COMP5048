## Data evalutation and visualisation of New York area airports
setwd("~/Documents/R/COMP5048")

# Load libraries
library(RSQLite)
library(ggplot2)
library(dplyr)
library(zoo)
library(RColorBrewer)

# Load airport data
airports <- as_tibble(read.csv("airports.csv", header = TRUE, stringsAsFactors = FALSE))
nycAirports <- c("EWR", "JFK", "LGA")

# Load carrier data
carriers <- as_tibble(read.csv("carriers.csv", header = TRUE, stringsAsFactors = FALSE))
# tidy up description for US Airwars
carriers[which(carriers$Code == "US"),"Description"] = substring(carriers[which(carriers$Code == "US"),"Description"], first = 1, last = 15)

# Read flights data from SQLite database
flightsDB <- dbConnect(RSQLite::SQLite(), dbname = "flights.sqlite3") # Create database connection
query <- paste('select year, month, dayofmonth, uniquecarrier, origin, dest, distance, arrdelay, depdelay, cancelled, diverted', 
               'from flights',
               'where (origin in ("JFK", "LGA", "EWR") or dest in ("JFK", "LGA", "EWR")) and year > 1999')
flights <- dbGetQuery(flightsDB, query) # Perform SQL query
dbDisconnect(flightsDB) # Disconnect from database after reading data

# Add column for date 
flights$Diverted <- as.factor(flights$Diverted)
flights$Cancelled <- as.factor(flights$Cancelled)
flights <- flights %>%
  mutate(Date = as.Date(paste(Year, Month, DayofMonth, sep = "-"), "%Y-%m-%d"),
         YearMonth = as.yearmon(paste(Year, Month, sep = "-"), "%Y-%m")) %>%
  as_tibble()

# Split dataset to arrivals and departures
departures <- flights %>% filter(Origin %in% nycAirports & Cancelled == 0) %>%
  mutate(DepDelay = replace(DepDelay, DepDelay < 0, 0))
arrivals <- flights %>% filter(Dest %in% nycAirports & Cancelled == 0 & Diverted == 0) %>% 
  mutate(ArrDelay = replace(ArrDelay, ArrDelay < 0, 0))

# Determine total number of flights, arrivals and departures
depCount <- departures %>% group_by(Date, Origin) %>% summarise(Count = n()) 
arrCount <- arrivals %>% group_by(Date, Dest) %>% summarise(Count = n()) 
totalCount <- arrCount %>% 
  left_join (depCount, by = c("Date", "Dest" = "Origin")) %>% 
  mutate(Total = Count.x + Count.y) %>% select(Date, Airport = Dest, Total)

# Total departures over time
ggplot(depCount, aes(x = Date, y = Count)) + geom_line(aes(col = Origin)) + 
  scale_color_brewer(palette = "Set1") + facet_wrap(~ Origin, ncol = 1) + #scale_x_yearmon() +
  labs(title = "Departures from EWR, JFK and LGA", subtitle = "US Domestic Flights",
       x = "Date", y = "Number of Flights") + theme_bw() + theme(legend.position = "none")

# Total arrivals over time
ggplot(arrCount, aes(x = Date, y = Count)) + geom_line(aes(col = Dest)) + 
  scale_color_brewer(palette = "Set1") + facet_wrap(~ Dest, ncol = 1) + #scale_x_yearmon() +
  labs(title = "Arrivals in EWR, JFK and LGA", subtitle = "US Domestic Flights",
       x = "Date", y = "Number of Flights") + theme_bw() + theme(legend.position = "none")

# Total flights over time
ggplot(totalCount, aes(x = Date, y = Total)) + geom_line(aes(col = Airport)) +
  scale_color_brewer(palette = "Set1") + facet_wrap(~ Airport, ncol = 1) + #scale_x_yearmon() +
  labs(title = "Total Domestic Flights", subtitle = "at EWR, JFK, and LGA") + 
  theme_bw() + theme(legend.position = "none")

# Determine number of cancellations and diversions
depCancelled <- flights %>% filter(Origin %in% nycAirports & Cancelled == 1) %>% 
  group_by(Date, Origin) %>% summarise(Cancellations = n())
arrCancelled <- flights %>% filter(Dest %in% nycAirports & Cancelled == 1) %>% 
  group_by(Date, Dest) %>% summarise(Cancellations = n())
totalCancelled <- arrCancelled %>%
  left_join(depCancelled, by = c("Date", "Dest" = "Origin")) %>%
  mutate(Total = Cancellations.x + Cancellations.y) %>% select(Date, Airport = Dest, Total)
totalCancelled$Total[is.na(totalCancelled$Total)] = 0

# Departures cancelled over time
ggplot(depCancelled, aes(x = Date, y = Cancellations)) + geom_line(aes(color = Origin)) +
  scale_color_brewer(palette = "Set1") + facet_wrap(~ Origin, ncol = 1) + #scale_x_yearmon() +
  labs(title = "Cancelled Departures", subtitle = "from EWR, JFK, and LGA", y = "Total") +
  theme(legend.position = "none") + theme_bw()

# Arrivals cancelled over time
ggplot(arrCancelled, aes(x = Date, y = Cancellations)) + geom_line(aes(color = Dest)) +
  scale_color_brewer(palette = "Set1") + facet_wrap(~ Dest, ncol = 1) + #scale_x_yearmon() +
  labs(title = "Cancelled Arrivals", subtitle = "at EWR, JFK, and LGA") +
  theme_bw() + theme(legend.position = "none")

# Total cancelled flights over time
ggplot(totalCancelled, aes(x = Date, y = Total)) + geom_line(aes(color = Airport)) +
  scale_color_brewer(palette = "Set1") + facet_wrap(~ Airport, ncol = 1) + #scale_x_yearmon() +
  labs(title = "Cancelled Flights", subtitle = "affecting EWR, JFK, and LGA") +
  theme_bw() + theme(legend.position = "none")

# Departures diverted over time
depDiverted <- flights %>% filter(Origin %in% nycAirports & Diverted == 1) %>% 
  group_by(Date, Origin) %>% summarise(Diversions = n())
ggplot(depDiverted, aes(x = Date, y = Diversions)) + geom_line(aes(color = Origin)) +
  scale_color_brewer(palette = "Set1") + facet_wrap(~ Origin, ncol = 1) + #scale_x_yearmon() +
  labs(title = "Diverted Departures", subtitle = "from EWR, JFK, and LGA") + 
  theme_bw() + theme(legend.position = "none")

# Arrivals diverted over time
arrDiverted <- flights %>% filter(Dest %in% nycAirports & Diverted == 1) %>% 
  group_by(Date, Dest) %>% summarise(Diversions = n())
ggplot(arrDiverted, aes(x = Date, y = Diversions)) + geom_line(aes(color = Dest)) +
  scale_color_brewer(palette = "Set1") + facet_wrap(~ Dest, ncol = 1) + #scale_x_yearmon() +
  labs(title = "Diverted Arrivals", subtitle = "from EWR, JFK, and LGA") + 
  theme_bw() + theme(legend.position = "none")

# Total diversions over time
totalDiverted <- arrDiverted %>%
  left_join(depDiverted, by = c("Date", "Dest" = "Origin")) %>%
  mutate(Total = Diversions.x + Diversions.y) %>% select(Date, Airport = Dest, Total)
totalDiverted$Total[is.na(totalDiverted$Total)] = 0
ggplot(totalDiverted, aes(x = Date, y = Total)) + geom_line(aes(color = Airport)) +
  scale_color_brewer(palette = "Set1") + facet_wrap(~ Airport, ncol = 1) + #scale_x_yearmon() +
  labs(title = "Diverted Flights", subtitle = "affecting EWR, JFK, and LGA") +
  theme_bw() + theme(legend.position = "none")

# Departure delay
departures %>% group_by(YearMonth, Origin) %>% summarise(AvgDelay = mean(DepDelay)) %>%
  ggplot(aes(x = YearMonth, y = AvgDelay)) + 
  geom_line(aes(col = Origin)) + facet_wrap(~ Origin, ncol = 1) + scale_x_yearmon() + 
  ylim(c(0,30)) + labs(title = "Average Departure Delay", x = "Date") + 
  theme_bw() + theme(legend.position = "none")

# Arrival delay
arrivals %>% group_by(YearMonth, Dest) %>% summarise(AvgDelay = mean(ArrDelay)) %>%
  ggplot(aes(x = YearMonth, y = AvgDelay)) + 
  geom_line(aes(col = Dest)) + facet_wrap(~ Dest, ncol = 1) + scale_x_yearmon() + 
  labs(title = "Average Arrival Delay", x = "Date") + theme_bw() + theme(legend.position = "none")

# Departure delay by airline
# determine top 5 airlines by departure frequency
depCarrier <- arrivals %>% group_by(UniqueCarrier) %>% summarise(Count = n()) %>% 
  arrange(desc(Count)) %>% filter(Count >= Count[5]) %>% select(UniqueCarrier) %>%
  left_join(carriers, by = c("UniqueCarrier" = "Code"))
# plot average departure delay by airline
departures %>% group_by(YearMonth, Origin, UniqueCarrier) %>% 
  filter(UniqueCarrier %in% depCarrier$UniqueCarrier) %>%
  summarise(Count = n(), AvgDelay = mean(DepDelay)) %>%
  ggplot(aes(x = YearMonth, y = AvgDelay)) + geom_line(aes(col = UniqueCarrier)) + 
  facet_wrap(~ Origin, ncol = 1) + scale_x_yearmon() + 
  scale_color_brewer(palette = "Set1", labels = depCarrier$Description) +
  labs(title = "Average Departure Delay") + theme_bw() + theme(legend.position = "top")

# Arrival delay by airline
# determine top 5 airlines by arrival frequency
arrCarrier <- arrivals %>% group_by(UniqueCarrier) %>% summarise(Count = n()) %>% 
  arrange(desc(Count)) %>% filter(Count >= Count[5]) %>% select(UniqueCarrier) %>%
  left_join(carriers, by = c("UniqueCarrier" = "Code"))

# plot average arrival delay by airline
arrivals %>% group_by(YearMonth, Dest, UniqueCarrier) %>% 
  filter(UniqueCarrier %in% depCarrier$UniqueCarrier) %>%
  summarise(Count = n(), AvgDelay = mean(ArrDelay)) %>%
  ggplot(aes(x = YearMonth, y = AvgDelay)) + geom_line(aes(col = UniqueCarrier)) + 
  facet_wrap(~ Dest, ncol = 1) + scale_x_yearmon() + 
  scale_color_brewer(palette = "Set1", labels = depCarrier$Description) +
  labs(title = "Average Arrival Delay") + theme_bw() + theme(legend.position = "top")