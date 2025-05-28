
library(tidyverse)
library(plotly)
library(htmlwidgets)
library(stringr)

# --- Càrrega i preprocessament ---
data <- read_csv("infra.csv", na = c("NA"))

data <- data %>%
  mutate(report_date = as.Date(report_date)) %>%
  mutate(across(starts_with("civic_buildings.ext_") | 
                  starts_with("educational_buildings.ext_") | 
                  starts_with("places_of_worship.ext_"),
                ~replace_na(., 0))) %>%
  select(report_date, 
         starts_with("civic_buildings.ext_"), 
         starts_with("educational_buildings.ext_"), 
         starts_with("places_of_worship.ext_"))

data_long <- data %>%
  pivot_longer(cols = -report_date, names_to = "type", values_to = "value") %>%
  mutate(type = str_replace(type, "^([^.]+)\\.ext_(.*)$", "\\1_\\2"))

noms_amigables <- tibble(
  type = c(
    "civic_buildings_destroyed",
    "educational_buildings_destroyed",
    "educational_buildings_damaged",
    "places_of_worship_mosques_destroyed", 
    #"places_of_worship_mosques_damaged",  # Eliminada la categoría dañada de mezquitas
    "places_of_worship_churches_destroyed"
  ),
  nom_amic = c(
    "Destroyed civic buildings", 
    "Destroyed educational buildings",
    "Damaged educational buildings",
    "Destroyed mosques", 
    #"Damaged mosques",               # Eliminada de etiquetas
    "Destroyed churches"
  )
)

ordre_factors <- c(
  "Destroyed mosques", 
  #"Damaged mosques",               # Eliminada de orden
  "Destroyed civic buildings", 
  "Destroyed educational buildings",
  "Damaged educational buildings",
  "Destroyed churches"
)

# Colores sin transparencia
colors_palestina <- c(
  "Destroyed mosques" = "#007A3D",
  #"Damaged mosques" = "#2EBF76", # Eliminado
  "Destroyed civic buildings" = "#CE1126",
  "Destroyed educational buildings" = "#000000",
  "Damaged educational buildings" = "#555555",
  "Destroyed churches" = "#0038B8"
)

data_long <- data_long %>%
  left_join(noms_amigables, by = "type") %>%
  mutate(
    nom_amic = if_else(is.na(nom_amic), type, nom_amic),
    nom_amic = factor(nom_amic, levels = ordre_factors)
  ) %>%
  filter(report_date <= as.Date("2025-04-28")) %>%
  # Eliminar explícitamente "Damaged mosques" si queda
  filter(nom_amic != "Damaged mosques") %>%
  arrange(nom_amic, report_date) %>%
  group_by(nom_amic) %>%
  mutate(value_acum = value) %>%
  ungroup() %>%
  mutate(
    fecha = format(report_date, "%d %b %Y"),
    hover_text = paste0(
      "<b style='color:#FF0000;'>", fecha, "</b><br>",
      "Type: ", nom_amic, "<br>",
      "Cumulative: ", value_acum
    ),
    contexto = paste0(
      "<div style='color:white; max-height:60vh; overflow-y:auto; padding:10px;'>",
      "<style>",
      "a.custom-link { all: unset !important; cursor: pointer !important; }",
      "div a.custom-link, div a.custom-link:hover {",
      "color: #FF0000 !important;",
      "border-bottom: 1px solid #FF0000 !important;",
      "}",
      ".tight-heading { margin: 0 0 8px 0 !important; line-height: 1.2 !important; }",
      "</style>",
      "<h2 style='color:#FF0000;'>", nom_amic, "</h2>",
      "<p style='color:#ccc; line-height:1.6;'>Date: ", fecha, "<br>Cumulative Count: ", value_acum, "</p>",
      "</div>"
    )
  )

# Assegura que totes les categories hi siguin des del principi
categories_completes <- tibble(
  report_date = min(data_long$report_date),
  nom_amic = factor(ordre_factors, levels = ordre_factors),
  value_acum = 0,
  hover_text = "",
  contexto = ""
)

data_long <- bind_rows(categories_completes, data_long)


for (categoria in ordre_factors) {
  df_categoria <- data_long %>% filter(nom_amic == categoria)
  plot_simple <- plot_simple %>%
    add_trace(
      data = df_categoria,
      x = ~report_date,
      y = ~value_acum,
      type = 'scatter',
      mode = 'none',
      name = categoria,
      fill = 'tonexty',
      stackgroup = 'one',
      fillcolor = colors_palestina[[as.character(categoria)]],  # Color sólido
      text = ~hover_text,
      hoverinfo = "text"
    )
}

plot_simple <- plot_simple %>%
  layout(
    paper_bgcolor = 'rgba(0,0,0,0.35)',
    plot_bgcolor = 'rgba(0,0,0,0)',
    title = list(
      text = "<b>Essential Infrastructures Damage</b>",
      font = list(size = 22, color = "white"),
      x = 0.05
    ),
    margin = list(t = 70, b = 70),
    legend = list(
      title = list(text = "<b>Infrastructure types</b>", font = list(color = "white")),
      font = list(size = 11, color = "white"),
      bgcolor = 'rgba(0,0,0,0.35)',  
      bordercolor = 'rgba(255,255,255,0.2)',  
      borderwidth = 1
    ),
    xaxis = list(
      title = "",
      gridcolor = 'rgba(255,255,255,0.15)',
      color = "white",
      tickfont = list(size = 12),
      range = c(min(data_long$report_date), as.Date("2025-04-28"))
    ),
    yaxis = list(
      title = list(
        text = "Acumulative",
        font = list(size = 14, color = "white")),
      gridcolor = 'rgba(255,255,255,0.15)',
      color = "white",
      tickfont = list(size = 12)
    ),
    hoverlabel = list(
      bgcolor = "rgba(0,0,0,0)",
      font = list(color = "black", size = 12),
      bordercolor = "white"
    )
  ) %>%
  config(displayModeBar = FALSE)

plot_simple

saveWidget(plot_simple, "infraestructures_damage.html", selfcontained = TRUE)


# ----------------- FACET --------------------#

facet_plot_static <- data_long %>%
  filter(nom_amic %in% ordre_factors) %>%
  ggplot(aes(x = report_date, y = value_acum, fill = nom_amic)) +
  geom_area(alpha = 0.5, color = NA) +
  scale_fill_manual(values = colors_palestina, name = "Tipus d'Infraestructura") +
  facet_wrap(~ nom_amic, nrow = 2, ncol = 4, scales = "free_y") +  # Ajusta per 7 categories, 4 columnes per exemple
  labs(
    title = "Infraestructures afectades per categoria",
    x = "Data",
    y = "Acumulatiu"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    strip.text = element_text(size = 10),
    plot.title = element_text(size = 14, hjust = 0),
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.minor = element_blank()
  )

# Mostrar el gràfic
facet_plot_static
