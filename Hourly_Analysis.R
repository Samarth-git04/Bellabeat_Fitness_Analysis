# Load required libraries
library(tidyverse)
library(lubridate)
library(janitor)
library(ggplot2)
library(scales)
library(tibble)

# Load CSV
hourly_merged <- read_csv("Combined_Data/hourly_merged.csv")
hourly_merged <- clean_names(hourly_merged)

# Correlation between Daily Steps and Calories Burned 
daily_usage <- hourly_merged %>%
  mutate(
    activity_hour = as.POSIXct(activity_hour, format = "%m/%d/%Y %I:%M:%S %p", tz = "UTC"),
    date = as.Date(activity_hour)
  ) %>%
  group_by(date) %>%
  summarise(
    total_calories = sum(calories, na.rm = TRUE),
    total_steps = sum(step_total, na.rm = TRUE)
  )

# Mean of Calories and Steps
daily_usage_mean <- hourly_merged %>%
  mutate(
    activity_hour = as.POSIXct(activity_hour, format = "%m/%d/%Y %I:%M:%S %p", tz = "UTC"),
    date = as.Date(activity_hour)
  ) %>%
  group_by(date) %>%
  summarise(
    mean_calories = mean(calories, na.rm = TRUE),
    mean_steps = mean(step_total, na.rm = TRUE)
  )

# Plot
ggplot(daily_usage_mean, aes(x = date)) +
  geom_line(aes(y = mean_steps * 1e-1, color = "Steps / 10")) +
  geom_line(aes(y = mean_calories, color = "Calories")) +
  scale_x_date(
    date_breaks = "1 week",        # breaks every week
    date_labels = "%d %b"          # e.g., "01 Jul"
  ) +
  scale_color_manual(values = c("Steps / 10" = "blue", "Calories" = "red")) +
  labs(title = "Daily Steps and Calories Burned", x = "Date", y = "Mean", color = "Metric") +
  coord_cartesian(ylim = c(0, 1e2)) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Pretty High correlation between total steps and total calories.
cor(daily_usage$total_steps, daily_usage$total_calories, use = "complete.obs")


# Average hourly intensity over time
intensity_trend <- hourly_merged %>%
  mutate(
    activity_hour = as.POSIXct(activity_hour, format = "%m/%d/%Y %I:%M:%S %p", tz = "UTC"),
    date = as.Date(activity_hour)
  ) %>%
  group_by(date) %>%
  summarise(
    avg_intensity = mean(average_intensity, na.rm = TRUE),
  )
str(intensity_trend$date)

# Plot
ggplot(intensity_trend, aes(x = date)) +
  geom_line(aes(y = avg_intensity, color = "Avg Intensity")) +
  labs(title = "Daily Intensity Trends", x = "Date", y = "Intensity Score", color = "Metric") +
  theme_minimal()