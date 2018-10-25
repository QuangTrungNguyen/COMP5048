''' Quang Trung Nguyen - qngu3976 - 470518197
Subject: COMP5048 Visual Analytics Assignment 1
Description: This file contains Python code to assign layers to Greek gods based on their ancestors count
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

#Import Greek Gods dataset
data = list(csv.DictReader(open('greek-gods.csv', encoding="utf8")))
#Clean data
for row in range(0,len(data)):
	data[row]['POPULARITY'] = int(data[row]['POPULARITY'])

#Recursive function to count ancestors
def find_parent(name):
   for i in range(0,len(data)):
      if data[i]['NAME'] == name:
         father = data[i]['FATHER'] 
         mother = data[i]['MOTHER']         
         if father == '' and mother == '':
            return 0
         elif father != '' and mother != '':
            return max(find_parent(mother), find_parent(father)) + 1
         elif father != '':
            return find_parent(father) + 1
         elif mother != '':
            return find_parent(mother) + 1
         
#Assign layers based on ancestors count       
gods = {}
layer = 0
for i in range(0,len(data)):
   name = data[i]['NAME']
   gods[name] = find_parent(name)
   if gods[name] > layer:
      layer = gods[name]

#No of layers
print(layer)
                  

            

      
