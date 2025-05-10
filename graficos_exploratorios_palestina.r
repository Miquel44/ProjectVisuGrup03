library(ggplot2)
library(dplyr)
library(plotly)
#Histograma, muertes en el tiempo
ggplot(casualties_daily, aes(x = report_date, y = ext_killed)) +
  geom_bar(stat = "identity", fill = "red") +labs(
    title = "Daily Killed Count Over Time",
    subtitle = paste("Data from", min(casualties_daily$report_date), "to", max(casualties_daily$report_date)),
    x = "Report Date",
    y = "Number of External Killed (ext_killed)"
  ) +
  theme_minimal() 


#Histograma interactivo 2024

Hist2024 <- ggplot(joined_data, aes(
  x = date, 
  y = -ext_killed,
  text = paste(
    "<b>Date:</b>", format(date, "%Y-%m-%d"), "<br>",
    "<b>Killed:</b>", ext_killed, "<br>",
    "<b>Context:</b> <a href='", url, "' target='_blank'>", content, "</a>"
  )
)) +
  geom_bar(stat = "identity", fill = "red", color = "red") +
  labs(
    title = "Daily Killed Count Over Time (2024)",
    x = "Report Date",
    y = "Number of External Killed (ext_killed)"
  ) +
  theme_minimal() +
  scale_y_continuous(labels = abs)

# Personalizar el tooltip con CSS y estilo
plot <- ggplotly(Hist2024, tooltip = "text") %>%
  style(
    hoverlabel = list(
      bgcolor = "#333333",  # Fondo oscuro
      font = list(color = "white", family = "Arial"),  # Texto blanco
      bordercolor = "lightgrey"  # Borde gris claro
    )
  )

plot
