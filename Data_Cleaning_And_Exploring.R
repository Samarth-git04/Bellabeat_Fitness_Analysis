# Load the libraries

library(tidyverse)
library(lubridate)
library(ggplot2)
#library(dplyr)
#library(skimr)
#library(here)
#library(purrr)
library(readr)

# Reading in all the CSVs. 
# Note : Unzip data file in Data before running this
daily_activity <- read_csv("Data/dailyActivity_merged.csv")
heartrate_seconds <- read_csv("Data/heartrate_seconds_merged.csv")
hourly_calories <- read_csv("Data/hourlyCalories_merged.csv")
hourly_intensities <- read_csv("Data/hourlyIntensities_merged.csv")
hourly_steps <- read_csv("Data/hourlySteps_merged.csv")
minute_Calories <- read_csv("Data/minuteCaloriesNarrow_merged.csv")
minute_Intensities <- read_csv("Data/minuteIntensitiesNarrow_merged.csv")
minute_METs <- read_csv("Data/minuteMETsNarrow_merged.csv")
minute_Steps <- read_csv("Data/minuteStepsNarrow_merged.csv")
minute_Sleep <- read_csv("Data/minuteSleep_merged.csv")
weight_Log <- read_csv("Data/weightLogInfo_merged.csv")

# Check all the column names
colnames(daily_activity)
colnames(heartrate_seconds)
colnames(hourly_calories)
colnames(hourly_intensities)
colnames(hourly_steps)
colnames(minute_Calories)
colnames(minute_Intensities)
colnames(minute_METs)
colnames(minute_Sleep)
colnames(minute_Steps)
colnames(weight_Log)

# Combine data on minute and hourly level
minute_merged <- reduce(list(minute_Calories, minute_Intensities, minute_METs
                              , minute_Steps), 
                         ~left_join(.x, .y, by = c("Id", "ActivityMinute")))
# Note: Haven't joined minute_sleep

hourly_merged <- reduce(list(hourly_calories, hourly_intensities, hourly_steps), 
                        ~left_join(.x, .y, by = c("Id", "ActivityHour")))

# Now we have heartrate_seconds, hourly_merged, minute_merged, minute_Sleep 
# and weight_Log tables with all the information.
# Remove the merged ones now
rm(hourly_intesities, hourly_calories, hourly_steps, minute_Calories, minute_Intensities, 
   minute_METs, minute_Steps, hourly_steps)


# Check for NA values 
sum(is.na(hourly_merged))
sum(is.na(minute_merged))
sum(is.na(heartrate_seconds))
sum(is.na(minute_Sleep))
sum(is.na(weight_Log)) # 31 our of 33

# Inspect weight_Log
weight_Log

# As there are a lot of NA values in Fat column I will not use it in my analysis 
# and hence I am dropping it from the table
weight_Log <- weight_Log %>% 
                select(-Fat)

# Check that it has been dropped 
weight_Log

# Check summary to better understand the tables
summary(heartrate_seconds)
summary(hourly_merged)
summary(minute_merged)
summary(minute_Sleep)
summary(weight_Log)

# Save them in separate Files after data cleaning
write_csv(daily_activity,    "Combined_Data/daily_activity.csv")
write_csv(heartrate_seconds, "Combined_Data/heartrate_seconds.csv")
write_csv(hourly_merged,     "Combined_Data/hourly_merged.csv")
write_csv(minute_merged,     "Combined_Data/minute_merged.csv")
write_csv(minute_Sleep,      "Combined_Data/minute_sleep.csv")
write_csv(weight_Log,        "Combined_Data/weight_log.csv")