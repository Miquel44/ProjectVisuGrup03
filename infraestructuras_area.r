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

# Colors inspirats en la bandera de Palestina + blau d’Israel per les esglésies
colors_palestina <- c(
  "Destroyed mosques" = "#007A3D",          # Verd fosc (Palestina)
  "Damaged mosques" = "#8CCB9B",            # Verd clar
  "Destroyed civic buildings" = "#CE1126",  # Vermell (Palestina)
  "Damaged civic buildings" = "#F4A7A7",    # Rosa clar
  "Destroyed educational buildings" = "#000000",  # Negre (Palestina)
  "Damaged educational buildings" = "#555555",    # Gris
  "Destroyed churches" = "#0038B8"          # Blau (Israel)
)

# Aplicar l'ordre dels factors
data_long <- data_long %>%
  mutate(nom_amic = factor(nom_amic, levels = ordre_factors))

# Crear l’animació
p <- ggplot(data_long, aes(x = report_date, y = value_acum, fill = nom_amic)) +
  geom_area(position = "stack", stat = "identity") +
  labs(title = 'Cumulative evolution of external infrastructure damage: {frame_along}', 
       x = "Date", y = "Cumulative value", fill = "Type") +
  scale_y_continuous(labels = scales::label_number(scale_cut = scales::cut_si(unit = ""))) +
  scale_fill_manual(values = colors_palestina) +
  theme_minimal(base_size = 16) +
  theme(legend.position = "right") +
  transition_reveal(along = report_date)

# Generar i guardar el GIF
anim <- animate(p, nframes = 100, fps = 10, width = 1000, height = 800, renderer = gifski_renderer())
anim_save("infrastructure_final.gif", animation = anim)
