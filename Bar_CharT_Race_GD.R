# --- Bar Chart Race Plotly ---
# Hombres vs Mujeres vs Niños
# --------------------------------------------------------------

# ── 0. Paquetes -----------------------------------------------------------------
required <- c("tidyverse", "lubridate", "zoo", "plotly", "htmlwidgets", "htmltools")
missing  <- required[!required %in% rownames(installed.packages())]
if (length(missing)) install.packages(missing)

library(tidyverse)
library(lubridate)
library(zoo)
library(plotly)
library(htmlwidgets)
library(htmltools)

# ── 1. Cargar datos -------------------------------------------------------------
data_path   <- "data/casualties_daily.csv"                   
output_path <- "server/public/graphs/types_of_death/bar_chart_race.html"

df_daily <- read_csv(data_path, show_col_types = FALSE) %>%
  mutate(report_date = as_date(report_date)) %>%
  filter(!is.na(ext_killed_cum))

# ── 2. Calcular series suavizadas ----------------------------------------------
calc_daily <- function(v) v - lag(v, default = 0)
win  <- 15
roll <- function(x) rollmean(x, k = win, fill = 0, align = "center")

df_smooth <- df_daily %>%
  arrange(report_date) %>%
  mutate(
    d_children = calc_daily(ext_killed_children_cum),
    d_women    = calc_daily(ext_killed_women_cum),
    d_total    = calc_daily(ext_killed_cum)) %>%
  mutate(d_men = pmax(d_total - d_children - d_women, 0)) %>%
  mutate(across(starts_with("d_"), roll, .names = "s_{col}")) %>%
  mutate(across(starts_with("s_d_"), cumsum, .names = "c_{col}"))

plot_df <- df_smooth %>%
  select(report_date,
         Niños   = c_s_d_children,
         Mujeres = c_s_d_women,
         Hombres = c_s_d_men) %>%
  filter(report_date >= as_date("2023-10-01"))

# ── 3. Formato largo y ranking --------------------------------------------------
plot_long <- plot_df %>%
  pivot_longer(-report_date, names_to = "group", values_to = "cumul") %>%
  group_by(report_date) %>%
  arrange(desc(cumul), .by_group = TRUE) %>%
  mutate(rank = row_number()) %>%
  ungroup() %>%
  mutate(date_str = format(report_date, "%Y-%m-%d"))

max_val <- max(plot_long$cumul) * 1.1

custom_colors <- c(
  "Hombres" = "#1f77b4",   # azul
  "Mujeres" = "#ff7f0e",   # naranja
  "Niños"   = "#2ca02c"    # verde
)

# ── 4. Plotly -------------------------------------------------------------------
p <- plot_ly(plot_long,
             x     = ~cumul,
             y     = ~reorder(group, -rank),
             frame = ~date_str,
             ids   = ~group,
             type  = "bar", orientation = "h",
             color = ~group, colors = custom_colors,
             hovertemplate = "%{y}: %{x}<extra></extra>") %>%
  layout(title = "Balance acumulado del impacto humano en Gaza y Cisjordania",
         xaxis = list(title = "Muertes acumuladas", range = c(0, max_val)),
         yaxis = list(title = ""),
         showlegend = FALSE,
         margin = list(l = 140)) %>%
  animation_opts(frame = 100, easing = "cubic-in-out", redraw = TRUE) %>%
  animation_slider(currentvalue = list(prefix = "Fecha: "))

# ── 5. Guardar solo el gráfico limpio -------------------------------------------
saveWidget(p, output_path, selfcontained = TRUE)
