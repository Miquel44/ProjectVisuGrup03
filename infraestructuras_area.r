#-----------------------ANIMATION---------------------#
library(tidyverse)
library(gganimate)
library(gifski)
library(stringr)

colors_palestina <- c(
  "Destroyed mosques" = "#007A3D",
  "Damaged mosques" = "#8CCB9B",
  "Destroyed civic buildings" = "#CE1126",
  "Damaged civic buildings" = "#F4A7A7",
  "Destroyed educational buildings" = "#000000",
  "Damaged educational buildings" = "#555555",
  "Destroyed churches" = "steelblue"
)

data_long <- data_long %>%
  mutate(nom_amic = as.character(nom_amic))

categories_completes <- tibble(
  report_date = min(data_long$report_date),
  nom_amic = unique(data_long$nom_amic),
  value_acum = 0
)

data_plot <- bind_rows(categories_completes, data_long %>% select(report_date, nom_amic, value_acum)) %>%
  arrange(report_date, nom_amic)

gg_area_anim <- ggplot(data_plot, aes(x = report_date, y = value_acum, fill = nom_amic)) +
  geom_area(stat = "identity", color = "black", size = 0.2, position = "stack") +
  scale_fill_manual(values = colors_palestina) +
  labs(
    title = "Cumulative Infrastructure Damage",
    x = "Date",
    y = "Count",
    fill = "Infrastructure Types"
  ) +
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = rgb(0, 0, 0, alpha = 0.5, maxColorValue = 255), color = NA),
    panel.background = element_rect(fill = rgb(0, 0, 0, alpha = 0.5, maxColorValue = 255), color = NA),
    legend.background = element_rect(fill = rgb(0, 0, 0, alpha = 0.5, maxColorValue = 255), color = 'black'),
    
    plot.title = element_text(color = "black", size = 16, face = "bold"),
    legend.title = element_text(face = "bold")
  ) +
  transition_reveal(along = report_date)


# Exportar frames .png amb transparència
animate(
  gg_area_anim,
  fps = 10,
  duration = 10,
  width = 800,
  height = 600,
  renderer = gifski_renderer('infra_gif.gif')  # Aquí canviem a gifski_renderer per sortir directament un gif
  # Opcional: si vols fons transparent
)



