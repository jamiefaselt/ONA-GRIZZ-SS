# Importing and mapping the Ag Census Variables -----------------------
# The existing list of variables that I am interested in investigating as predictors
# for grizzly regression are as follows:
# Source: STATCAN AG CENSUS 2016 <https://www150.statcan.gc.ca/n1/en/type/data?cansim=004-0200%2C004-0201%2C004-0202%2C004-0203%2C004-0204%2C004-0205%2C004-0206%2C004-0207%2C004-0208%2C004-0209%2C004-0210%2C004-0211%2C004-0212%2C004-0213%2C004-0214%2C004-0215%2C004-0216%2C004-0217%2C004-0218%2C004-0219%2C004-0220%2C004-0221%2C004-0222%2C004-0223%2C004-0224%2C004-0225%2C004-0226%2C004-0227%2C004-0228%2C004-0229%2C004-0230%2C004-0231%2C004-0232%2C004-0233%2C004-0234%2C004-0235%2C004-0236%2C004-0237%2C004-0238%2C004-0239%2C004-0240%2C004-0241%2C004-0242%2C004-0243%2C004-0244%2C004-0245%2C004-0246&p=1-All#all>
# 1. land use - land in crops, summerffallow land, seeded pasture, natural land, woodland/wetland, other
# 2. farm type - cattle ranching, beef, pork, poultry, sheep, goat, veg, grain, nursery, fruits
# 3. fruits n nuts - # of farms, acres of coverage
# 4. bees - bees on census day, # of farms and total bees
# 5. land practices & land features - winter grazing/feeding, rotational grazing, plowing green crops, winter cover crops, windbreaks

# Each of these datasets come with a .csv file for that section of the census data and a metadata .csv file

# Load Packages -----------------------------------------------------------
library(tidyverse)
library(dplyr)
install.packages("raster")
library("raster")
library("sp")
library("sf")
install.packages("sjmisc")
library("sjmisc")

# Import Files ------------------------------------------------------------
farm.type <- read.csv("/Users/shannonspragg/ONA_GRIZZ/Ag census/farm type_32100403/farm type_32100403.csv")
# Classification code = type of farm
land.use <- read.csv("/Users/shannonspragg/ONA_GRIZZ/Ag census/land use_32100406/land use_32100406.csv")
fruits.n.nuts <- read.csv("/Users/shannonspragg/ONA_GRIZZ/Ag census/fruits n nuts_32100417/fruits n nuts_32100417.csv")
bees <- read.csv("/Users/shannonspragg/ONA_GRIZZ/Ag census/bees_32100432/bees_32100432.csv")
land.practice <- read.csv("/Users/shannonspragg/ONA_GRIZZ/Ag census/land practices and features_32100411/land practices_32100411.csv")


# Download CanCensus Spatial Data -----------------------------------------
install.packages("cancensus")
library(cancensus)
options(cancensus.api_key="CensusMapper_02c70bf223570cf6f5dec048e9ee7e14")
cancensus.cache_path="canc"
install.packages("geojsonsf")
library(geojsonsf)
library(tidyverse)
library("sf")

# To view available Census datasets
list_census_datasets()

# To view available named regions at different levels of Census hierarchy for the 2016 Census (for example)
list_census_regions("CA16") # Row 4, number 59 is BC

# To view available Census variables for the 2016 Census
list_census_vectors("CA16","region"=="59")
bc.census.data<-list_census_vectors("CA16","region"=="59")

# I went with the below route to see if that works better instead:
# Read in the .shp for Canada census divisions data:
cen.divs.shp <-st_read("/Users/shannonspragg/ONA_GRIZZ/CAN Spatial Data/census divisions_can/lcd_000b16a_e.shp")

# Make sure it is an sf object
cd.sf<- as(cen.divs.shp, "sf")
bc.ab.cen.divs<-cd.sf %>%
  filter(., PRNAME == "British Columbia" | PRNAME == "Alberta") %>%
  st_make_valid()
# This is somehow only returning alberta stuff...

# Spatialize the Ag Files -------------------------------------------------

# Filter the Ag Files down to just BC districts:
# See here: https://www.statology.org/filter-rows-that-contain-string-dplyr/  searched: 'Return rows with partial string, filter dplyr'
farm.type.bc <- farm.type %>% filter(grepl("British Columbia", GEO)) 
land.use.bc <- land.use %>% filter(grepl("British Columbia", GEO)) 
fruits.nuts.bc <- fruits.n.nuts %>% filter(grepl("British Columbia", GEO)) 
bees.bc <- bees %>% filter(grepl("British Columbia", GEO)) 
land.prac.bc <- land.practice %>% filter(grepl("British Columbia", GEO)) 

# Join the BC Census Districts with Ag Files:


