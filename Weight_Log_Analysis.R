library(tidyverse)
library(lubridate)

weight_Log <- read.csv("Combined_Data/weight_Log.csv")
heartrate_seconds <- read_csv("Combined_Data/heartrate_seconds.csv")

# Convert Date in weight_Log
weight_Log <- weight_Log %>%
  mutate(Date = as.Date(Date, format = "%m/%d/%Y"))

# Convert Time in heartrate_seconds
heartrate_seconds <- heartrate_seconds %>%
  mutate(Time = mdy_hms(Time))

# Basic summary stats
summary(weight_Log)
summary(heartrate_seconds)

# Aggregate to Average Daily Heartrate
hr_daily <- heartrate_seconds %>%
  mutate(Date = as.Date(Time)) %>%
  group_by(Id, Date) %>%
  summarise(daily_avg_hr = mean(Value, na.rm = TRUE), .groups = "drop")

# Join with weight data
combined_daily <- hr_daily %>%
  inner_join(weight_Log, by = c("Id", "Date"))


# Histogram of WeightKg
ggplot(weight_Log, aes(x = WeightKg)) +
  geom_histogram(binwidth = 5, fill = "skyblue", color = "black") +
  labs(title = "Distribution of Weight (Kg)", x = "Weight (Kg)", y = "Count") +
  theme_minimal()

# Histogram of BMI
ggplot(weight_Log, aes(x = BMI)) +
  geom_histogram(binwidth = 2, fill = "salmon", color = "black") +
  labs(title = "Distribution of BMI", x = "BMI", y = "Count") +
  theme_minimal()

# Calculate correlation between heart rate and weight
cor_hr_weight <- round(cor(combined_daily$WeightKg, combined_daily$daily_avg_hr, use = "complete.obs"), 2)

# No significant correlation found
print(cor(combined_daily$WeightKg, combined_daily$daily_avg_hr, use = "complete.obs"))

# Now plot with correlation in title
ggplot(combined_daily, aes(x = WeightKg, y = daily_avg_hr)) +
  geom_point(alpha = 0.6, color = "purple") +
  geom_smooth(method = "lm", se = FALSE, color = "black") +
  labs(
    title = paste0("Daily Avg Heart Rate vs Weight (Kg) (r = ", cor_hr_weight, ")"),
    x = "Weight (Kg)",
    y = "Avg Heart Rate (BPM)"
  )