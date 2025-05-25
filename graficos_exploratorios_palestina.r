library(ggplot2)
library(dplyr)
library(plotly)
#Histograma, muertes en el tiempo



#Histograma interactivo 2024

Hist2024 <- ggplot(joined_data, aes(
  x = date, 
  y = -ext_killed,
  text = paste(
    "<b>Date:</b>", format(date, "%Y-%m-%d"), "<br>",
    "<b>Killed:</b>", ext_killed, "<br>",
    "<b>Context:</b> <a href='", url, "' target='_blank'>", content, "</a>"
  )
)) +
  geom_bar(stat = "identity", fill = "red", color = "red") +
  labs(
    title = "Daily Killed Count Over Time (2024)",
    x = "Report Date",
    y = "Number of External Killed (ext_killed)"
  ) +
  theme_minimal() +
  scale_y_continuous(labels = abs)

# Personalizar el tooltip con CSS y estilo
plot <- ggplotly(Hist2024, tooltip = "text") %>%
  style(
    hoverlabel = list(
      bgcolor = "#333333",  # Fondo oscuro
      font = list(color = "white", family = "Arial"),  # Texto blanco
      bordercolor = "lightgrey"  # Borde gris claro
    )
  )

plot


library(ggplot2)
library(plotly)
library(htmlwidgets)
library(dplyr)

# Preprocesar datos: truncar contenido a 50 palabras
joined_data2 <- joined_data %>%
  mutate(
    truncated_content = sapply(strsplit(content, "\\s+"), function(x) {
      words <- x[1:pmin(50, length(x))]
      if(length(x) > 50) words <- c(words, "... [continúa]")
      paste(words, collapse = " ")
    })
  )

# 1. Crear gráfico con dos conjuntos de datos
Hist2024 <- ggplot(joined_data2, aes(
  x = date, 
  y = -ext_killed,
  # Texto para hover (HTML simple)
  text = paste(
    "<b>Fecha:</b>", format(date, "%Y-%m-%d"), "<br>",
    "<b>Muertes:</b>", ext_killed
  ),
  # Datos personalizados para el modal (HTML completo)
  customdata = paste(
    "<div style='max-height:300px; overflow-y:auto; padding:10px;'>",
    "<b>Fecha:</b>", format(date, "%Y-%m-%d"), "<br>",
    "<b>Muertes:</b>", ext_killed, "<br><br>",
    "<b>Contexto:</b><br>", 
    "<a href='", url, "' target='_blank' style='color: #88f;'>",
    truncated_content, "</a>",
    "</div>"
  )
)) +
  geom_bar(stat = "identity", fill = "red", color = "red") +
  labs(
    title = "Daily Killed Count Over Time (2024)",
    x = "Report Date",
    y = "Number of External Killed (ext_killed)"
  ) +
  theme_minimal() +
  scale_y_continuous(labels = abs)

# 2. Convertir a Plotly con tooltip HTML
plot <- ggplotly(Hist2024, tooltip = "text") %>%
  layout(hoverlabel = list(
    bgcolor = "rgba(0,0,0,0.8)",
    font = list(color = "white")
  ))
  
  # 3. Modificar el JavaScript para el modal
  plot <- htmlwidgets::onRender(plot, "
function(el) {
  el.on('plotly_click', function(d) {
    var point = d.points[0];
    var content = point.customdata;
    
    // Crear modal moderno
    var modal = document.createElement('div');
    modal.innerHTML = `
      <div style='
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: #1a1a1a;
        color: white;
        padding: 20px;
        border-radius: 10px;
        z-index: 1000;
        max-width: 600px;
        width: 90%;
        box-shadow: 0 0 20px rgba(0,0,0,0.5);
        max-height: 80vh;
        overflow: hidden;
        display: flex;
        flex-direction: column;
      '>
        <div style='flex-grow: 1; overflow-y: auto; padding-right: 10px;'>
          ${content}
        </div>
        <button onclick='this.parentElement.remove()' 
          style='
            margin-top: 15px;
            padding: 8px 20px;
            background: #444;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            align-self: flex-end;
          '>
          Cerrar
        </button>
      </div>
    `;
    
    // Fondo oscuro
    var overlay = document.createElement('div');
    overlay.style = `
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0,0,0,0.7);
      z-index: 999;
    `;
    
    // Manejar cierre
    overlay.onclick = function() {
      document.body.removeChild(overlay);
      document.body.removeChild(modal);
    };
    
    document.body.appendChild(overlay);
    document.body.appendChild(modal);
  });
}
")
  
  # 4. Mostrar el gráfico
print(plot)
  
  # Guardar como HTML
htmlwidgets::saveWidget(plot, "interactive_plot_final.html", selfcontained = TRUE)
  
