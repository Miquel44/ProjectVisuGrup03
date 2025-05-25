library(plotly)
library(readr)

# Cargar CSV
df <- read_csv("df_killed_injured_cum.csv")
df$date <- as.character(df$report_date)

# Crear gráfico
p <- plot_ly() %>%
  add_bars(
    data = df,
    x = ~date,
    y = ~ext_killed_cum,
    textposition = "none",
    text = ~date,
    hoverinfo = "text",
    marker = list(
      color = 'crimson',
      opacity = 0.8,
      line = list(color = '#333', width = 1)
    ),
    name = "Muertes acumuladas"
  ) %>%
  add_trace(
    data = df,
    x = ~date,
    y = ~ext_killed_cum,
    type = "scatter",
    mode = "lines",
    fill = "tozeroy",
    line = list(color = "darkred", width = 2),
    fillcolor = "rgba(220, 20, 60, 0.1)",
    hoverinfo = "skip",
    name = "Tendencia"
  ) %>%
  layout(
    title = list(
      text = "<b>Muertes acumuladas por fecha</b>",
      x = 0.5,
      font = list(
        family = "Open Sans, sans-serif",
        size = 22,
        color = "#222"
      )
    ),
    xaxis = list(
      title = "Fecha",
      tickangle = -45,
      tickfont = list(family = "Open Sans", size = 12),
      tickmode = "auto",
      nticks = 10
    ),
    yaxis = list(
      title = "Muertes acumuladas",
      tickfont = list(family = "Open Sans", size = 12)
    ),
    font = list(family = "Open Sans, sans-serif", size = 12),
    margin = list(b = 100, l = 60, r = 30, t = 70),
    plot_bgcolor = "#fff",
    paper_bgcolor = "#fff",
    showlegend = FALSE
  )

# Click redirige al viewer
p <- htmlwidgets::onRender(p, "
  function(el, x) {
    el.on('plotly_click', function(d) {
      var date = d.points[0].x;
      window.location.href = 'viewer.html?date=' + date;
    });
  }
")

# Guardar
htmlwidgets::saveWidget(p, "index.html", selfcontained = TRUE)
