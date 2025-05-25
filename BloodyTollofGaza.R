library(plotly)
library(htmlwidgets)
library(dplyr)

# Preprocesamiento de datos con hover y popup modificado
joined_data <- joined_data %>%
  rowwise() %>%
  mutate(
    fecha = format(date, "%d %b %Y"),
    hover_text = paste0(
      "<span style='color: #FF0000; font-weight: bold;'>",  # Fecha en rojo y negrita
      format(date, "%d/%m/%Y"), 
      "</span><br>",
      "<span style='color: #FF0000;'>",  # Todo el texto de víctimas en rojo
      "Victims: ", ext_killed, 
      "</span>"
    ),
    contexto = paste0(
      "<div style='max-height:60vh; overflow-y:auto; padding:5px 10px 0 0; color:white;'>  <!-- Reduced top padding -->
    <style>
      /* Reset completo de estilos para enlaces */
      a.custom-link {
        all: unset !important;
        cursor: pointer !important;
      }
      
      /* Estilos personalizados con máxima especificidad */
      div a.custom-link,
      div a.custom-link:link,
      div a.custom-link:hover,
      div a.custom-link:active,
      div a.custom-link:focus,
      div a.custom-link:visited {
        color: #FF0000 !important;
        text-decoration: none !important;
        border-bottom: 1px solid #FF0000 !important;
        transition: all 0.3s !important;
        background-image: none !important;
        -webkit-tap-highlight-color: transparent !important;
      }

      div a.custom-link:hover {
        border-bottom-color: #FF6666 !important;
      }

      /* Nuevos ajustes de espaciado */
      .tight-heading {
        margin: 0 0 8px 0 !important;  <!-- Reducido de 15px a 8px -->
        line-height: 1.2 !important;
      }
    </style>
    <h2 style='color:#FF0000; margin:0 0 8px 0;'>Deaths today: ", ext_killed, "</h2>  
    <p style='color:#ccc; line-height:1.6; margin-top:0;'>", 
      content_processed, 
      "</p>
    <a href='", url, "' target='_blank' class='custom-link' style='color:#FF0000 !important;'>
      Read more
    </a>
  </div>"
    )
  )%>%
  ungroup()

# Crear gráfico con hover personalizado
plot <- plot_ly(joined_data) %>%
  add_bars(
    x = ~date,
    y = ~-ext_killed,
    text = ~hover_text,
    hoverinfo = "text",
    marker = list(
      color = 'rgba(255, 0, 0, 1)',
      line = list(width = 3, color = 'rgba(255, 0, 0, 1)')
    ),
    customdata = ~contexto
  ) %>%
  layout(
    title = list(
      text = "<b>The Bloody toll of gaza</b>",
      font = list(size = 24, color = 'white', family = 'Arial Black')
    ),
    xaxis = list(
      title = "",
      gridcolor = 'rgba(255,255,255,0.1)',
      linecolor = 'rgba(255,255,255,0.5)',
      tickfont = list(color = 'white', size = 12)
    ),
    yaxis = list(
      title = "",
      showticklabels = FALSE,  # Oculta las etiquetas del eje Y
      showgrid = FALSE,        # Oculta la cuadrícula
      zeroline = FALSE,        # Oculta la línea cero
      showline = FALSE         # Oculta la línea del eje
    ),
    plot_bgcolor = 'black',
    paper_bgcolor = 'black',
    margin = list(t = 60, b = 40, l = 60, r = 40),
    hoverlabel = list(
      font = list(family = 'Arial', size = 12, color = 'white'),
      bgcolor = 'rgba(0,0,0,0.8)'
    )
  ) %>%
  config(displayModeBar = FALSE)

# Añadir interactividad con modal oscuro (el mismo código se mantiene)
plot <- htmlwidgets::onRender(plot, "
function(el) {
  el.on('plotly_click', function(d) {
    const point = d.points[0];
    
    const overlay = document.createElement('div');
    overlay.className = 'custom-overlay';
    overlay.style = `
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0,0,0,0.9);
      z-index: 1000;
      display: flex;
      justify-content: center;
      align-items: center;
      backdrop-filter: blur(5px);
    `;
    
    const modal = document.createElement('div');
    modal.style = `
      background: #111;
      color: white;
      border-radius: 12px;
      width: 90%;
      max-width: 600px;
      max-height: 90vh;
      overflow: hidden;
      box-shadow: 0 10px 30px rgba(0,0,0,0.5);
      animation: modalIn 0.3s ease-out;
      border: 1px solid #333;
    `;
    
    modal.innerHTML = `
      <div style='padding: 25px;'>
        ${point.customdata}
      </div>
      <div style='
        background: #000;
        padding: 15px;
        text-align: right;
        border-top: 1px solid #222;
      '>
        <button onclick='document.querySelector(\".custom-overlay\").remove()'
          style='
            background: #333;
            color: white;
            border: 1px solid #444;
            padding: 8px 20px;
            border-radius: 5px;
            cursor: pointer;
            transition: all 0.2s;
          '
          onmouseover='this.style.background=\"#444\"'
          onmouseout='this.style.background=\"#333\"'>
          Cerrar
        </button>
      </div>
    `;
    
    overlay.appendChild(modal);
    document.body.appendChild(overlay);
    
    const style = document.createElement('style');
    style.textContent = `
      @keyframes modalIn {
        0% { transform: translateY(20px); opacity: 0; }
        100% { transform: translateY(0); opacity: 1; }
      }
    `;
    document.head.appendChild(style);
  });
}
")

saveWidget(plot, "VictimasDiarias.html", selfcontained = TRUE, 
           title = "Monitor de Conflictos Armados")
