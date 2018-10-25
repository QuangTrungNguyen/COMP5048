# Load library for correlation task
library(corrgram)
library(corrplot)


# Arrival Delay

ArrDelay <- read.csv('query_dest_arrival delay.csv')
cor_data <- data.frame(ArrDelay$arr_delay_time,
                       ArrDelay$num_of_flights,
                       ArrDelay$flight_time, 
                       ArrDelay$distance,
                       ArrDelay$carrier_delay,
                       ArrDelay$weather_delay,
                       ArrDelay$nas_delay,
                       ArrDelay$security_delay,
                       ArrDelay$late_aircraft_delay)

colnames(cor_data) <- c("DelayTime", "NumFlight","FlightTime","Distance",
                        "carrier_delay","WeatherDelay",
                        "NasDelay", "SecurityDelay",
                        "LateAircraftDelay")
cor_data_num = as.data.frame(sapply(cor_data, as.numeric))


corrplot(cor(na.omit(cor_data_num)) , method = "circle", type = "upper",
         tl.srt = 25, tl.col = "Black", tl.cex = 1, title = "Correlation between 
         Arrival Delay time & Potential Delay Factors from 2000 to 2008", 
         mar =c(0, 0, 4, 0) + 0.1)


# Departure Delay


DepDelay <- read.csv('query_origin_departure delay.csv')
cor_data <- data.frame(DepDelay$arr_delay_time,
                       DepDelay$num_of_flights,
                       DepDelay$flight_time, 
                       DepDelay$distance,
                       DepDelay$carrier_delay,
                       DepDelay$weather_delay,
                       DepDelay$nas_delay,
                       DepDelay$security_delay,
                       DepDelay$late_aircraft_delay)

colnames(cor_data) <- c("DelayTime", "NumFlight","FlightTime","Distance",
                        "carrier_delay","WeatherDelay",
                        "NasDelay", "SecurityDelay",
                        "LateAircraftDelay")
cor_data_num = as.data.frame(sapply(cor_data, as.numeric))


corrplot(cor(na.omit(cor_data_num)) , method = "circle", type = "upper",
         tl.srt = 25, tl.col = "Black", tl.cex = 1, title = "Correlation between 
         Departure Delay time & Potential Delay Factors from 2000 to 2008", 
         mar =c(0, 0, 4, 0) + 0.1)



