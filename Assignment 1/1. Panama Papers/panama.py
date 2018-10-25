''' Quang Trung Nguyen - qngu3976 - 470518197
Subject: COMP5048 Visual Analytics Assignment 1
Description: This file contains Python code to transform data for Panama Papers to format suitable for d3.js
Date: 14/09/2017
'''
from lxml import html
import requests
import re
import csv
import matplotlib.pyplot as plt; plt.rcdefaults()
import numpy as np
import matplotlib.pyplot as plt
import pprint
import random

colors = []
name = ''
country = {}
countrylist = []
keys = []
output = ''

#Open source file
file = open("panama.txt","r")

status = True

#Read each line
for i in range (1,1054): 
   text = file.readline().strip()
   if status:
      name = text.replace(":",'').replace("{",'').strip()
      if name not in countrylist:
         countrylist.append(name)
      status = False
   elif text != "}":
      index = text.find(":")
      cty = text[:index]
      num = text[index+2:]
      country[cty] = num
      if cty not in countrylist:
         countrylist.append(cty)
   elif text == "}":
      for key in country:
         keys.append(key)
      for j in range (0,len(keys)):
         output += '["' + name + '","' + keys[j] + '",' + country[keys[j]] + "],\n"
      country.clear()
      keys.clear()
      name = ''
      status = True
file.close()

#Write to output file
file2 = open("chord.txt","w")
file2.write(output)
file2.close()
countrylist.sort()
print(countrylist)

#Write countries in sorted order to output file
file3 = open("sort.txt","w")
for i in range(0,len(countrylist)):
   file3.write('"' + countrylist[i] + '",\n')
file3.close()

#Assign random colors to each country
file4 = open("color.txt","w")
for i in range(0,len(countrylist)):
   r = lambda: random.randint(0,255)
   color = '#%02X%02X%02X' % (r(),r(),r())
   while color in colors:
      r = lambda: random.randint(0,255)
      color = '#%02X%02X%02X' % (r(),r(),r())
   colors.append(color)
   file4.write('"' + countrylist[i] + '":        "' + color + '",\n')
file4.close()



  
   
