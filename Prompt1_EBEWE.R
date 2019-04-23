####################################################################################
######PROMPT 1: EXISTING BUILDINGS ENERGY & WATER EFFICIENCY PROGRAM ANALYSIS#######
####################################################################################

#YOU WILL BE ANALYZING THE MAYOR'S OFFICE OPEN DATA ON THE EBEWE ORDINANCE
##YOU CAN BEGIN BY DOWNLOADING THE DATA AS A CSV FILE FROM THE GEOHUB HERE:https://data.lacity.org/A-Livable-and-Sustainable-City/Existing-Buildings-Energy-Water-Efficiency-EBEWE-P/9yda-i4ya

#libraries I recommend downloading for your analysis
##make sure to do install.packages() first if you don't have these
library(dplyr)
library(tidyverse)
library(readr)

#you should start by getting and setting up your working directory (based on where you saved your file)
getwd() #this will tell you where your directory currently is set to 
#here's how I set up my directory...
setwd("/Users/cassieelizabethhalls/Documents/Winter_Quarter_19/codecamp/") #this will allow you to choose your file path for your directory
ebewe <- read_csv("Existing_Buildings_Energy_Water_Efficiency_EBEWE_Program.csv")

#you can start by looking at the data, the size and characteristics
glimpse(ebewe)
View(ebewe)
#how many variables are there? how many observations?

#you will need to clean the data a bit and remove NA values from each vector to run a histogram and other analysis 

#I would begin by understanding the data a bit- you can create some histograms, plots etc.
##for example...

#Since we have data over time, we would also be interested in trends over time, 
##outlier analysis and analysis around whether outliers continue to stay as outliers 
##or some of them are beginning to merge to the mean? Outliers could be on either side of the histogram - 
###what are examples or categories of buildings performing better than the average as well as lot worse. 
