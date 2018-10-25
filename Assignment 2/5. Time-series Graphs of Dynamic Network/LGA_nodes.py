import sqlite3

def formatDate(date):
   if date < 10:
      return '0' + str(date)
   else:
      return str(date)

def getDate(month, year):
   if month in (1,3,5,7,8,10,12):
      return '31'
   elif month in (4,6,9,11):
      return '30'
   elif month == 2 and year == 2000:
      return '29'
   elif month == 2 and year != 2000:
      return '28'
      

def addNode(start, end):
   return '<node id="' + airport + '" label="' + airport + '" start="' + start + '" end="' + end + '" >\n  <attvalues>\n    <attvalue for="lat" value=""></attvalue>\n    <attvalue for="lng" value=""></attvalue>\n  </attvalues>\n</node>\n'   
   
conn = sqlite3.connect("ontime.sqlite3")
c = conn.cursor()


airports = []
c.execute('SELECT Distinct Origin from flight Where Dest = "LGA" and Year != 1999 Order by Origin')
origin = c.fetchall()
c.execute('SELECT Distinct Dest from flight Where Origin = "LGA" and Year != 1999 Order by Dest')
dest = c.fetchall()
for i in range(0, len(origin)):
   airports.append(origin[i][0])
for i in range(0, len(dest)):
   if dest[i][0] not in airports:
      airports.append(dest[i][0])
airports.sort()
print(airports)




final_output = ""

for i in range(0,len(airports)):
   

   c.execute('SELECT count(*), Month, Year from flight Where (Origin = "LGA" and Dest = "' + airports[i] + '" and Year != 1999) or (Origin = "' + airports[i] + '" and Dest = "LGA" and Year != 1999) Group by Year,Month')
   data = c.fetchall()


   airport = airports[i]

   year = ""
   month = ""

   start = ""
   end = ""

   output = ""
 

   for i in range(0,len(data)):
      if i == 0:
         month = formatDate(data[0][1])      
         year = formatDate(data[0][2])
         start = year + '-' + month + '-' + '01'
         if len(data) == 1:
            end = year + '-' + month + '-' + getDate(int(month),int(year))
            output += addNode(start, end)
      elif i > 0:
         if data[i][2] != int(year) and data[i][1] != 1:
            end = year + '-' + month + '-' + getDate(int(month),int(year))
            output += addNode(start, end)
         
            month = formatDate(data[i][1])      
            year = formatDate(data[i][2])
            start = year + '-' + month + '-' + '01'
            if i ==  len(data) - 1:
               end = year + '-' + month + '-' + getDate(int(month),int(year))
               output += addNode(start,end);
         elif data[i][2] == int(year) and data[i][1] > int(month) + 1:
            end = year + '-' + month + '-' + getDate(int(month),int(year))
            output += addNode(start, end)   
         
            month = formatDate(data[i][1])  
            start = year + '-' + month + '-' + '01'
            if i ==  len(data) - 1:
               end = year + '-' + month + '-' + getDate(int(month),int(year))
               output += addNode(start,end);
         else:
            month = formatDate(data[i][1]) 
            year = formatDate(data[i][2])
            if i ==  len(data) - 1:
               end = year + '-' + month + '-' + getDate(int(month),int(year))
               output += addNode(start,end);
         
   final_output = final_output + output + '\n' 
conn.close()

#Write data to a CSV file
with open('LGA_nodes.TXT', 'w') as lga:
   lga.write(final_output)

