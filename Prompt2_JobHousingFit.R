#############################################################################################################
###############PROMPT 1: EXISTING BUILDINGS ENERGY & WATER EFFICIENCY PROGRAM ANALYSIS#######################
#############################################################################################################


#YOU WILL BE ANALYZING THE CITY OF LA's HOUSING AND JOB STATISTICS, AND BUILDING A JOB-HOUSING FIT
##HERE IS A GOOD SIMPLE DISCRIPTION OF WHAT GOES INTO A JOB HOUSING FIT: https://shelterforce.org/2017/05/25/jobs-housing-fit/

#HERE'S A RUN DOWN OF HOW TO BUILD A JOB-HOUSING FIT FOR LA COUNTY. WE RECOMMEND THAT YOU SPLIT UP THE TASKS ACROSS THE GROUPS

#Part 1- Download and visualize the data 
#(1) Download and use ACS to identify the location (tracts) of affordable rental units [they need to figure out a standard, preferably from existing policies]
#(2) Download and use LEHD to identify the location (tracts) of low wage (earnings) jobs by work site 
#(3) Create a simple index of low-wage jobs to affordable housing. J-H Fit index
#(4) Visually (and statistically if possible) analyze and describe the overall spatial patterns

#Part 2, using index to assess location of new affordable units
#(1) Download and use most recent HUD data on LIHTC by tract.
#(2) Download and use most recent Section 8 voucher data by tract
#(3) Merge and analyze with respect to J-H fit index
#(4) Interpret, are units being placed in areas of high need relative to J-H fit

#Useful resources:
#https://www.hud.gov/program_offices/comm_planning/affordablehousing/
#https://1p08d91kd0c03rlxhmhtydpr-wpengine.netdna-ssl.com/wp-content/uploads/2018/06/Full-LA-County-Outcomes-Report-with-Appendices.pdf

#libraries I recommend downloading for your analysis
##make sure to do install.packages() first if you don't have these
library(dplyr)
library(readr)
library(tidyverse)
library(tidycensus) #a good guide on using tidycensus here:http://zevross.com/blog/2018/10/02/creating-beautiful-demographic-maps-in-r-with-the-tidycensus-and-tmap-packages/
library(viridis) #used with tidycensus 
library(tigris)#pulling tract shape files (TIGER/LINE files)
library(leaflet) #interactive mapping
library(tmap) #one option for mapping your data, a tutorial here: 
library(tmaptools)
library(ggplot2) #when you use ggplot, remember you can review our module for this:https://ucla-data-archive.github.io/intro-r-tidyv/05-visualization/index.html

#############################################################################################################
######################PART 1a: DOWNLOADING DATA FROM THE ACS THROUGH TIDYCENSUS##############################
#############################################################################################################

#(1) Download and use ACS to identify the location (tracts) of affordable rental units [they need to figure out a standard, preferably from existing policies]

#put in your census API key
census_api_key("5b1f730bcca4850efc9b1a1ec1524832412fabb9", install = TRUE)

#first, you need to find the varaible 
viewvar <- load_variables(2015, "acs5", cache=TRUE) 
View(viewvar) #all of the variables in the ACS are coded with six character name, you will need to find the code for the housing data you are interested in pulling
#you look for "median housing costs"
#you will need to define what you think is affordable, here are some standards you could base this on: https://la.curbed.com/2018/5/16/17354052/affordable-housing-requirements-income-limits-los-angeles

housing_aff <- get_acs(geography = "tract", table = "B25104", year = 2017, state = "CA", county = "Los Angeles", geometry = TRUE, keep_geo_vars = TRUE, survey = "acs5")
glimpse(housing_aff) #use this to take a glance at the variables, number of observations, and string types for this data 

View(housing_aff)

#DSC-- NEED HELP HERE! 
#I NEED TO REPLACE ALL THESE VARIABLE NAMES WITH THE MEDIAN VALUE RANGES I THINK-- NOT SURE HOW TO PROCEED HERE
## NEED TO SOMEHOW FILTER BY THE TRACTS THAT HAVE AFFORDABLE HOUSING


#############################################################################################################
####################PART 1b: DOWNLOADING & MAPPING DATA FROM LEHD ON LOW-WAGE JOBS ##########################
#############################################################################################################

#(2) Download and use LEHD to identify the location (tracts) of low wage (earnings) jobs by work site 

#Due to time limitations, we include instructions for cleaning the data file from the Longitudinal Employer Household Dynamics Program ready for you
##Please download from the following website:https://lehd.ces.census.gov/data/
##you need the following file at the bottom of the page called "ca_od_main_JT05_2015.csv.gz"
###The technical document on the data is available here: https://lehd.ces.census.gov/data/lodes/LODES7/LODESTechDoc7.3.pdf


#you should start by getting and setting up your working directory (based on where you saved your file)
getwd() #this will tell you where your directory currently is set to 
#here's how I set up my directory...
setwd("/Users/cassieelizabethhalls/Documents/Winter_Quarter_19/TOE_LODES")
LODES_data <- read_csv("ca_od_main_JT00_2015.csv")
##DON'T OPEN IN EXCEL, READ IT DIRECTLY INTO R STUDIO

#sorting and filtering the data for LA County, categorizing low-wage 
LODES_LA <- LODES_data %>% filter(str_detect(w_geocode,("^06037"))) #this might take a while to load

LODES_LA_Final <- LODES_LA %>% filter(str_detect(h_geocode,("^06037"))) #this might take a while to load

LODES_selected <- dplyr::select(LODES_LA_Final,"w_geocode", "h_geocode","S000", "SE01", "SE02", "SE03")

LODES_selected_merged <- mutate(LODES_selected, TotalLowWage = SE01 + SE02)  

LODES_selected_merged2 <- dplyr::select(LODES_selected_merged, "w_geocode", "h_geocode","S000", "SE03", "TotalLowWage")
names(LODES_selected_merged2) <- c("Workplace_FIPS", "Residence_FIPS", "All_Jobs", "Higher_Wage_Earners", 
                                   "Lower_Wage_Earners_Merged")

#aggregating data up to the tract level 

LODES_selected_merged3 <- LODES_selected_merged2 %>% 
  mutate(Workplace_tracts = substr(Workplace_FIPS, 1, 11), 
         Residence_tracts = substr(Residence_FIPS, 1, 11)) 

LODES_selected_merged4 <- select(LODES_selected_merged3, "All_Jobs", "Higher_Wage_Earners", "Lower_Wage_Earners_Merged", 
                                   "Workplace_tracts")

#Now view your clean data file! 
View(LODES_selected_merged4)

#Now, map your data! 
LA_CT <- tracts("California", "Los Angeles") #might take a while to load
plot(LA_CT) #this is a plot of just the tracts 
job_tracts <- append_data(LA_CT, LODES_selected_merged4, key.shp = "GEOID", 
                          key.data = "Workplace_tracts", ignore.duplicates = TRUE) #now you are joining these tracts with job data
qtm(job_tracts, fill = "Lower_Wage_Earners_Merged") #a quick map of the jobs
#NEED TO ALSO INCLUDE MAPPING OF ACS DATA 


#############################################################################################################
#################################PART 1c: JOB-HOUSING FIT INDEX ############################################
#############################################################################################################

#(3) Create a simple index of low-wage jobs to affordable housing. J-H Fit index

#(4) Visually (and statistically if possible) analyze and describe the overall spatial patterns



#############################################################################################################
#################################PART 2: JOB-HOUSING FIT INDEX: HUD DATA ###################################
#############################################################################################################

#Part 2, using index to assess location of new affordable units
#(1) Download and use most recent HUD data on LIHTC by tract here AS A SPREADSHEET: http://hudgis-hud.opendata.arcgis.com/datasets/low-income-housing-tax-credit-properties
##DON'T OPEN IN EXCEL, READ IT DIRECTLY INTO R STUDIO

#(2) Download and use most recent Section 8 voucher data by tract

#(3) Merge and analyze with respect to J-H fit index

#(4) Interpret, are units being placed in areas of high need relative to J-H fit


