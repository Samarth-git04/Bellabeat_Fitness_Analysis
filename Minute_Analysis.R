library(tidyverse)
library(lubridate)
library(scales)

minute_merged <- read_csv("Combined_Data/minute_merged.csv")
minute_Sleep <- read_csv("Combined_Data/minute_Sleep.csv")

# Fixing the format for ActivityMinute
minute_merged <- minute_merged %>%
  mutate(ActivityMinute = parse_date_time(ActivityMinute, orders = "mdy HMS"))

# Fixing the format for minute_Sleep
minute_Sleep <- minute_Sleep %>%
  mutate(date = parse_date_time(date, orders = "mdy IMS p"))

# Aggregate minute-level data to daily-level
daily_minute <- minute_merged %>%
  mutate(day = date(ActivityMinute)) %>%
  group_by(Id, day) %>%
  summarise(
    daily_calories = sum(Calories, na.rm = TRUE),
    daily_steps = sum(Steps, na.rm = TRUE),
    daily_mets = sum(METs, na.rm = TRUE),
    avg_intensity = mean(Intensity, na.rm = TRUE),
    .groups = "drop"
  )

# Aggregate sleep data to daily-level
daily_sleep <- minute_Sleep %>%
  mutate(day = date(date)) %>%
  group_by(Id, day) %>%
  summarise(
    sleep_minutes = n(),  
    .groups = "drop"
  )

# Combine the data
combined_minute_sleep <- left_join(daily_minute, daily_sleep, by = c("Id", "day"))

# Find Correlations
cor_steps_sleep <- round(cor(combined_minute_sleep$sleep_minutes, 
                             combined_minute_sleep$daily_steps,
                              use = "complete.obs"), 2)

cor_mets_sleep <- round(cor(combined_minute_sleep$sleep_minutes, 
                      combined_minute_sleep$daily_mets, 
                      use = "complete.obs"), 2)


# Plot
ggplot(combined_minute_sleep, aes(x = sleep_minutes, y = daily_steps)) +
  geom_point(alpha = 0.6, color = "steelblue") +
  geom_smooth(method = "lm", se = FALSE, color = "black") +
  labs(
    title = paste0("Daily Steps vs Sleep Duration (minutes)(r = ", cor_steps_sleep ,")"),
    x = "Sleep Duration (minutes)",
    y = "Steps"
  )

ggplot(combined_minute_sleep, aes(x = sleep_minutes, y = daily_mets)) +
  geom_point(alpha = 0.5, color = "purple") +
  geom_smooth(method = "lm", se = FALSE, color = "black") +
  labs(
    title = paste0("Daily METs vs Sleep Duration (minutes) (r = ", cor_mets_sleep ,")"),
    x = "Sleep Duration (minutes)",
    y = "METs"
  )