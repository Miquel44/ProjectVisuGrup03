#-----------------------ANIMATION---------------------#

library(tidyverse)
library(gganimate)
library(stringr)

# Directori i càrrega de dades
setwd('C:\\Users\\minaa\\OneDrive\\Escritorio\\Documentos\\EDD\\3r any\\2n Semestre\\VD\\Projecte\\ProjectVisuGrup03-main\\data')
data <- read_csv("infra.csv", na = c("NA"))

# Conversió de dates
data <- data %>% mutate(report_date = as.Date(report_date))

# Neteja de NAs
data <- data %>%
  mutate(across(starts_with("civic_buildings.ext_") | 
                  starts_with("educational_buildings.ext_") | 
                  starts_with("places_of_worship.ext_"),
                ~replace_na(., 0)))

# Selecció i transformació a format long
data_ext <- data %>%
  select(report_date, 
         starts_with("civic_buildings.ext_"), 
         starts_with("educational_buildings.ext_"), 
         starts_with("places_of_worship.ext_"))

data_long <- data_ext %>%
  pivot_longer(cols = -report_date, names_to = "type", values_to = "value") %>%
  mutate(type = str_replace(type, "^([^.]+)\\.ext_(.*)$", "\\1_\\2"))

# Traducció dels noms a anglès
noms_amigables <- tibble(
  type = c(
    "civic_buildings_destroyed", 
    "civic_buildings_damaged",
    "educational_buildings_destroyed",
    "educational_buildings_damaged",
    "places_of_worship_mosques_destroyed", 
    "places_of_worship_mosques_damaged", 
    "places_of_worship_churches_destroyed"
  ),
  nom_amic = c(
    "Destroyed civic buildings", 
    "Damaged civic buildings",
    "Destroyed educational buildings",
    "Damaged educational buildings",
    "Destroyed mosques", 
    "Damaged mosques", 
    "Destroyed churches"
  )
)

# Unió amb noms i càlcul acumulat
data_long <- data_long %>%
  left_join(noms_amigables, by = "type") %>%
  mutate(nom_amic = if_else(is.na(nom_amic), type, nom_amic)) %>%
  arrange(nom_amic, report_date) %>%
  group_by(nom_amic) %>%
  mutate(value_acum = cumsum(value)) %>%
  ungroup()

# Ordre personalitzat (per a l'stacking)
ordre_factors <- c(
  "Destroyed mosques", 
  "Damaged mosques",
  "Destroyed civic buildings", 
  "Damaged civic buildings",
  "Destroyed educational buildings",
  "Damaged educational buildings",
  "Destroyed churches"
)

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



