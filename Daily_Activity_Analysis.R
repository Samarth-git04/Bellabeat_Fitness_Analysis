library(tidyverse)
library(lubridate)

# Load and preprocess
daily_activity <- read_csv("Combined_Data/daily_activity.csv") %>%
  mutate(ActivityDate = mdy(ActivityDate))

# Removed some outliers 
daily_activity <- daily_activity %>%
  filter(FairlyActiveMinutes <= 600)

# Prepare data
activity_long <- daily_activity %>%
  select(TotalSteps, VeryActiveMinutes, FairlyActiveMinutes, LightlyActiveMinutes, SedentaryMinutes) %>%
  pivot_longer(
    cols = -TotalSteps,
    names_to = "ActivityType",
    values_to = "Minutes"
  )

# Calculate correlations per activity type
cor_values <- activity_long %>%
  group_by(ActivityType) %>%
  summarise(cor_val = cor(TotalSteps, Minutes, use = "complete.obs"))

# Join correlations to activity_long for facets
activity_long <- activity_long %>%
  left_join(cor_values, by = "ActivityType") %>%
  mutate(
    ActivityLabel = paste0(ActivityType, "\nCorrelation: ", round(cor_val, 3))
  )

# Plot
ggplot(activity_long, aes(x = TotalSteps, y = Minutes)) +
  geom_point(alpha = 0.4, color = "steelblue") +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  facet_wrap(~ ActivityLabel, scales = "free_y") +
  labs(
    title = "Correlation between Total Steps and Activity Minutes",
    x = "Total Steps",
    y = "Minutes"
  ) +
  theme_minimal() +
  theme(
    strip.text = element_text(size = 12, face = "bold")
  )