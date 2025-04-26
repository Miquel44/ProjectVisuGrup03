library(ggplot2)
library(dplyr)
#Histograma, muertes en el tiempo
ggplot(casualties_daily, aes(x = report_date, y = ext_killed)) +
  geom_bar(stat = "identity", fill = "red") +labs(
    title = "Daily Killed Count Over Time",
    subtitle = paste("Data from", min(casualties_daily$report_date), "to", max(casualties_daily$report_date)),
    x = "Report Date",
    y = "Number of External Killed (ext_killed)"
  ) +
  theme_minimal() 
