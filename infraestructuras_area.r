library(tidyverse)
library(plotly)
library(htmlwidgets)
library(stringr)

# --- Carga y preprocessament ---
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
  "Destroyed churches" = "#0038B8FF"
)

data_long <- data_long %>%
  left_join(noms_amigables, by = "type") %>%
  mutate(
    nom_amic = if_else(is.na(nom_amic), type, nom_amic),
    nom_amic = factor(nom_amic, levels = ordre_factors)
  ) %>%
  filter(report_date <= as.Date("2024-04-30")) %>%
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
      "<div style='color:white; max-height:60vh; overflow-y:auto; padding:10px;'>
        <style>
          a.custom-link { all: unset !important; cursor: pointer !important; }
          div a.custom-link, div a.custom-link:hover {
            color: #FF0000 !important;
            border-bottom: 1px solid #FF0000 !important;
          }
          .tight-heading { margin: 0 0 8px 0 !important; line-height: 1.2 !important; }
        </style>
        <h2 style='color:#FF0000;'>", nom_amic, "</h2>
        <p style='color:#ccc; line-height:1.6;'>Date: ", fecha, "<br>Cumulative Count: ", value_acum, "</p>
      </div>"
    )
  )

categories_completes <- tibble(
  report_date = min(data_long$report_date),
  nom_amic = factor(ordre_factors, levels = ordre_factors),
  value_acum = 0,
  hover_text = "",
  contexto = ""
)

data_long <- bind_rows(categories_completes, data_long)

missing_colors <- setdiff(unique(data_long$nom_amic), names(colors_palestina))
if (length(missing_colors) > 0) {
  stop("Falten colors per als següents tipus: ", paste(missing_colors, collapse = ", "))
}

plot_simple <- plot_ly(
  data = data_long,
  x = ~report_date,
  y = ~value_acum,
  color = ~nom_amic,
  colors = colors_palestina,
  text = ~hover_text,
  hoverinfo = "text",
  type = 'scatter',
  mode = 'none',
  stackgroup = 'one',
  fill = 'tonexty',
  opacity = 1
) %>% 
  layout(
    paper_bgcolor = 'rgba(0, 0, 0, 0.5)',
    plot_bgcolor = 'rgba(255, 255, 255, 1)',
    title = list(
      text = "<b>Essential Infrastructure Damage</b>",
      font = list(size = 22, color = "white"),
      x = 0.05
    ),
    margin = list(t = 70, b = 70),
    legend = list(
      title = list(text = "<b>Infrastructure Type</b>", font = list(color = "white")),
      font = list(size = 14, color = "white"),
      bgcolor = 'rgba(0,0,0,0.5)'
    ),
    xaxis = list(
      title = "",
      gridcolor = 'rgba(255,255,255,0.2)',
      color = "white",
      tickfont = list(size = 12)
    ),
    yaxis = list(
      title = list(
        text = "Cumulative Damage Count",
        font = list(size = 14, color = "white")),
      gridcolor = 'rgba(255,255,255,0.2)',
      color = "white",
      tickfont = list(size = 12)
    ),
    hoverlabel = list(
      bgcolor = "rgba(255,255,255,0.9)",
      font = list(color = "black", size = 12),
      bordercolor = "white"
    )
  ) %>%
  config(displayModeBar = FALSE)  # Esta línea elimina la barra de herramientas

# Guardar el widget
html_file <- "plot_infra_opaque.html"
saveWidget(plot_simple, file = html_file, selfcontained = TRUE)
