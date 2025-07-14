# Load required libraries
library(tidyverse)
library(lubridate)

# Read data from Data/ folder
heartrate_seconds <- read_csv("Combined_Data/heartrate_seconds.csv")
hourly_merged <- read_csv("Combined_Data/hourly_merged.csv")
weight_Log <- read_csv("Combined_Data/weight_Log.csv")


# Convert Time in heartrate_seconds
heartrate_seconds <- heartrate_seconds %>%
  mutate(Time = mdy_hms(Time))

# Convert ActivityHour in hourly_merged
hourly_merged <- hourly_merged %>%
  mutate(activity_hour = mdy_hms(ActivityHour))

# Convert Date in weight_Log
weight_Log <- weight_Log %>%
  mutate(Date = as.Date(Date, format = "%m/%d/%Y"))


# Make it hourly heartrate
hr_hourly <- heartrate_seconds %>%
  mutate(hour = floor_date(Time, "hour")) %>%
  group_by(Id, hour) %>%
  summarise(avg_hr = mean(Value, na.rm = TRUE), .groups = "drop")

# Check their summary as a sanity check before merge
summary(length(hr_hourly))
summary(length(hourly_merged$Id))

# Merge heart rate and activity data
combined_hourly <- hr_hourly %>%
  inner_join(hourly_merged, by = c("Id", "hour" = "activity_hour"))


# Calculate correlations
cor_hr_calories <- round(cor(combined_hourly$Calories, combined_hourly$avg_hr, use = "complete.obs"),2)
cor_hr_intensity <- round(cor(combined_hourly$TotalIntensity, combined_hourly$avg_hr, use = "complete.obs"),2)

# Plot 1: Heart Rate vs Calories
ggplot(combined_hourly, aes(x = Calories, y = avg_hr)) +
  geom_point(alpha = 0.3, color = "darkred") +
  geom_smooth(method = "lm", se = FALSE, color = "blue") +
  labs(
    title = paste("Hourly Avg Heart Rate vs Calories Burned (r =", cor_hr_calories, ")"),
    x = "Calories Burned",
    y = "Avg Heart Rate (BPM)"
  ) +
  theme_minimal()

# Plot 2: Heart Rate vs Total Intensity
ggplot(combined_hourly, aes(x = TotalIntensity, y = avg_hr)) +
  geom_point(alpha = 0.3, color = "darkgreen") +
  geom_smooth(method = "lm", se = FALSE, color = "blue") +
  labs(
    title = paste("Hourly Avg Heart Rate vs Total Intensity (r =", cor_hr_intensity, ")"),
    x = "Total Intensity",
    y = "Avg Heart Rate (BPM)"
  ) +
  theme_minimal()


