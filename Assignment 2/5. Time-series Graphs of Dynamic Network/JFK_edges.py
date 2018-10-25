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
      

def addEdge(origin, count, year, month, date):
   return '<edge source="' + origin + '" target="JFK" start="' + year + '-' + month + '-01" end="' + year + '-' + month + '-' + date + '" weight="' + count + '" />'
   

output = ""

conn = sqlite3.connect("ontime.sqlite3")
c = conn.cursor()

for year in range(2000,2004):
   for month in range(1,13):
      output += '\n'
      c.execute('SELECT Origin, Count(*) From flight Where Dest = "JFK" and Year = ' + str(year) + ' and Month = ' + str(month) + ' Group by Origin')
      arr = c.fetchall()
      c.execute('SELECT Dest, Count(*) From flight Where Origin = "JFK" and Year = ' + str(year) + ' and Month = ' + str(month) + ' Group by Dest')
      dep = c.fetchall()
      
      
      for i in range(0, len(arr)):
         add = 0
         for j in range(0, len(dep)):
            if arr[i][0] == dep[j][0]:
               add = dep[j][1]
         output = output + addEdge(arr[i][0], str(arr[i][1] + add), formatDate(year), formatDate(month), getDate(month,year)) + '\n'

      for m in range(0, len(dep)):
         overLap = False
         for n in range(0, len(arr)):
            if dep[m][0] == arr[n][0]:
               overLap = True
         if overLap == False:
            output = output + addEdge(dep[m][0], str(dep[m][1]), formatDate(year), formatDate(month), getDate(month,year)) + '\n'     
   
conn.close()

#Write data to a CSV file
with open('JFK_edges.TXT', 'w') as edge:
   edge.write(output)

