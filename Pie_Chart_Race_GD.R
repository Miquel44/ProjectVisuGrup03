# 0 · Paquetes --------------------------------------------------------------------
req <- c("tidyverse", "lubridate", "zoo", "plotly", "htmltools")
install.packages(setdiff(req, rownames(installed.packages())), quiet = TRUE)

suppressPackageStartupMessages({
  library(tidyverse); library(lubridate); library(zoo); library(plotly); library(htmltools)
})

# 1 · Leer datos ------------------------------------------------------------------
raw <- read_csv("data/casualties_daily.csv", show_col_types = FALSE) %>%
  mutate(report_date = as_date(report_date)) %>% arrange(report_date)

# 2 · Helpers ---------------------------------------------------------------------
calc_daily <- function(v) v - lag(v, default = 0)
roll15     <- function(x) rollmean(x, 15, fill = 0, align = "center")

make_pie <- function(df, groups) {
  tmp <- df
  for (col in groups) {
    d <- paste0("d_", col); s <- paste0("s_", d); c <- paste0("c_", s)
    tmp[[d]] <- calc_daily(tmp[[col]]); tmp[[s]] <- roll15(tmp[[d]]); tmp[[c]] <- cumsum(tmp[[s]])
  }
  long <- tmp %>% select(report_date, all_of(set_names(paste0("c_s_d_", groups), names(groups)))) %>%
    filter(report_date >= as_date("2023-10-01")) %>%
    pivot_longer(-report_date, names_to = "group", values_to = "value") %>%
    mutate(value = round(value), frame = format(report_date, "%Y-%m-%d"))
  
  cols <- set_names(c("#ffffff", "#d40000", "#009f3d"), names(groups))
  
  plot_ly(long, type = "pie",
          labels = ~group, values = ~value, ids = ~group, frame = ~frame,
          textinfo = "label+value", hoverinfo = "none",
          marker = list(colors = cols), showlegend = FALSE)
}

# 3 · Construir pies --------------------------------------------------------------
aug <- raw %>% mutate(ext_killed_men_cum = pmax(ext_killed_cum - ext_killed_children_cum - ext_killed_women_cum, 0))

pie_dem <- make_pie(aug,
                    c("Niños"="ext_killed_children_cum", "Mujeres"="ext_killed_women_cum", "Hombres"="ext_killed_men_cum"))

pie_pro <- make_pie(raw,
                    c("Sanitarios"="ext_med_killed_cum", "Prensa"="ext_press_killed_cum", "Defensa Civil"="ext_civdef_killed_cum"))

# 4 · Dominios (más grandes) -------------------------------------------------------
pie_dem$x$attrs[[1]]$domain <- list(x = c(0.02, 0.48), y = c(0.12, 0.88))
pie_pro$x$attrs[[1]]$domain <- list(x = c(0.52, 0.98), y = c(0.12, 0.88))

# 5 · Combinar & layout -----------------------------------------------------------
combined <- subplot(pie_dem, pie_pro, nrows = 1, widths = c(0.5, 0.5), shareX = FALSE) %>%
  layout(
    paper_bgcolor = "rgba(0,0,0,0)",  # fondo transparente, lo aportará el div
    plot_bgcolor  = "rgba(0,0,0,0)",
    height = 800,
    margin = list(l = 10, r = 10, t = 170, b = 160),
    annotations = list(
      list(text = "Balance Acumulado de Fallecidos", x = 0.5, y = 1.2, xref = "paper", yref = "paper",
           showarrow = FALSE, xanchor = "center", font = list(color = "#ffffff", size = 22)),
      list(text = "Hombres, Mujeres y Niños", x = 0.25, y = 1.04, xref = "paper", yref = "paper",
           showarrow = FALSE, xanchor = "center", font = list(color = "#ffffff", size = 18)),
      list(text = "Personal Sanitario, Prensa y Defensa Civil", x = 0.75, y = 1.04, xref = "paper", yref = "paper",
           showarrow = FALSE, xanchor = "center", font = list(color = "#ffffff", size = 18))
    )
  ) %>%
  animation_opts(frame = 100, easing = "linear", redraw = TRUE) %>%
  animation_slider(
    currentvalue = list(prefix = "Fecha: ", font = list(size = 18, color = "#ffffff")),
    bgcolor = "rgba(255,255,255,0.2)",
    tickcolor = "#ffffff",
    font = list(color = "#ffffff")
  ) %>%
  config(displayModeBar = FALSE)

# 6 · CSS para slider / botón Play -------------------------------------------------
custom_css <- tags$style(HTML(".plotly .slider g.tick text, .plotly .slider g.tick line {fill:#ffffff !important; stroke:#ffffff !important;}\n.plotly .slider .handle, .plotly .slider .slider-handle {fill:#ffffff !important; stroke:#ffffff !important;}\n.plotly .slider .slider-line, .plotly .slider line {stroke:#ffffff !important;}\n.plotly .slider button {color:#ffffff !important; border:1px solid #ffffff !important;}"))

# 7 · HTML wrapper ----------------------------------------------------------------
page <- browsable(div(style = "background:rgba(0,0,0,0.5);width:100vw;height:100vh;", custom_css, combined))

# 8 · Guardar ---------------------------------------------------------------------
output_dir <- "server/public/graphs/types_of_death"; dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
htmltools::save_html(page,
                     file = file.path(output_dir, "piechart_race_combined.html"),
                     libdir = "libs")

message("✔ HTML exportado a ", file.path(output_dir, "piechart_race_combined.html"))


