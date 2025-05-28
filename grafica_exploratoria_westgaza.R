library(ggplot2)
library(dplyr)
library(plotly)
library(htmlwidgets)

# Calcular morts diàries a partir d'acumulades
combined_daily <- combined_filled %>%
  group_by(region) %>%
  arrange(report_date) %>%
  mutate(daily_killed = killed - lag(killed, default = 0)) %>%
  ungroup()

# Gràfic de barres apilades acumulades
p <- ggplot(combined_filled, aes(x = report_date, y = killed, fill = region,
                                 text = paste("Data:", report_date,
                                              "<br>Morts acumulades:", killed))) +
  geom_bar(stat = "identity", position = "stack", alpha=1) +
  scale_fill_manual(values = c("Gaza" = "#ef1107", "West Bank" = "black")) +
  labs(
    title = "Morts acumulades entre Gaza i Cisjordània",
    subtitle = "Evolució acumulada diària per regió",
    x = "Data",
    y = "Morts acumulades",
    fill = "Regió"
  ) +
  scale_x_date(date_breaks = "2 months", date_labels = "%Y-%m") +
  theme(
    axis.title.x = element_text(margin = margin(t = 10)),
    axis.title.y = element_text(margin = margin(r = 2)),
    plot.background = element_rect(fill = "transparent", color = NA),  # transparent ggplot background
    panel.background = element_rect(fill = "transparent", color = NA)
  )

# Convertir a plotly amb fons transparent
plotly_plot <- ggplotly(p, tooltip = "text") %>%
  layout(
    paper_bgcolor = 'rgba(0,0,0,0)',
    plot_bgcolor = 'rgba(0,0,0,0)',
    yaxis = list(autorange = TRUE)  # <-- Aquesta línia és la clau
  )


# Guardar com HTML
saveWidget(plotly_plot, "grafico_morts.html", selfcontained = TRUE, background = "transparent")





#--------------WEST BANK----------------------------------#



# Filtrar només West Bank
westbank_only <- combined_filled %>%
  filter(region == "West Bank")

# Gràfic només per West Bank
p <- ggplot(westbank_only, aes(x = report_date, y = killed, fill = region,
                               text = paste("Data:", report_date,
                                            "<br>Morts acumulades:", killed))) +
  geom_bar(stat = "identity", position = "stack", alpha = 1) +
  scale_fill_manual(values = c("West Bank" = "black")) +
  labs(
    title = "Morts acumulades a Cisjordània",
    subtitle = "Evolució acumulada diària",
    x = "Data",
    y = "Morts acumulades",
    fill = "Regió"
  ) +
  theme_minimal() +
  scale_x_date(date_breaks = "2 months", date_labels = "%Y-%m") +
  theme(
    axis.title.x = element_text(margin = margin(t = 10)),
    axis.title.y = element_text(margin = margin(r = 2))
  )

# Versió interactiva
ggplotly(p, tooltip = "text")


#------------------------------------GAZA----------------------------#
# Filtrar només Gaza
gaza_only <- combined_filled %>%
  filter(region == "Gaza")

# Gràfic només per Gaza
p <- ggplot(gaza_only, aes(x = report_date, y = killed, fill = region,
                           text = paste("Data:", report_date,
                                        "<br>Morts acumulades:", killed))) +
  geom_bar(stat = "identity", position = "stack", alpha = 1) +
  scale_fill_manual(values = c("Gaza" = "#ef1107")) +
  labs(
    title = "Morts acumulades a Gaza",
    subtitle = "Evolució acumulada diària",
    x = "Data",
    y = "Morts acumulades",
    fill = "Regió"
  ) +
  theme_minimal() +
  scale_x_date(date_breaks = "2 months", date_labels = "%Y-%m") +
  theme(
    axis.title.x = element_text(margin = margin(t = 10)),
    axis.title.y = element_text(margin = margin(r = 2))
  )

# Versió interactiva
ggplotly(p)
