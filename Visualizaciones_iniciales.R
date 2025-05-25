library(ggplot2)
library(tidyr)
library(tibble)

# Muertes y heridos por día
p1 <- ggplot(df_killed_injured_perday, aes(x = report_date)) +
  geom_line(aes(y = ext_killed, color = "Muertos diarios")) +
  geom_line(aes(y = ext_injured, color = "Heridos diarios")) +
  labs(
    title = "Muertes y Heridos Diarios en Gaza",
    x = "Fecha",
    y = "Número de personas",
    color = "Leyenda"
  ) +
  theme_minimal()

ggsave(
  filename = "plots/muertes_heridos_dia.png",
  plot = p1,
  width = 10,
  height = 6,
  dpi = 300
)

# Muertes y heridos acumulados
p2 <- ggplot(df_killed_injured_cum, aes(x = report_date)) +
  geom_line(aes(y = ext_killed_cum, color = "Muertos acumulados")) +
  geom_line(aes(y = ext_injured_cum, color = "Heridos acumulados")) +
  labs(
    title = "Muertes y Heridos Acumulados en Gaza",
    x = "Fecha",
    y = "Número acumulado de personas",
    color = "Leyenda"
  ) +
  theme_minimal()

ggsave(
  filename = "plots/muertes_heridos_acumulados.png",
  plot = p2,
  width = 10,
  height = 6,
  dpi = 300
)

# Demografía: mujeres, niños y otros
p3 <- ggplot(df_demographics, aes(x = report_date)) +
  geom_line(aes(y = ext_killed_children_cum, color = "Niños muertos acumulados")) +
  geom_line(aes(y = ext_killed_women_cum, color = "Mujeres muertas acumuladas")) +
  geom_line(aes(y = killed_other_cum, color = "Otros muertos acumulados")) +
  labs(
    title = "Distribución de Muertes por Grupos Demográficos",
    x = "Fecha",
    y = "Número acumulado",
    color = "Grupos"
  ) +
  theme_minimal()

ggsave(
  filename = "plots/muertes_demografia.png",
  plot = p3,
  width = 10,
  height = 6,
  dpi = 300
)

# Periodistas, médicos, emergencia
p4 <- ggplot(df_personnel, aes(x = report_date)) +
  geom_line(aes(y = ext_civdef_killed_cum, color = "Personal emergencia muerto")) +
  geom_line(aes(y = ext_press_killed_cum, color = "Periodistas muertos")) +
  geom_line(aes(y = ext_med_killed_cum, color = "Médicos muertos")) +
  labs(
    title = "Muertes de Personal Sanitario, Prensa y Emergencias",
    x = "Fecha",
    y = "Número acumulado",
    color = "Categoría"
  ) +
  theme_minimal()

ggsave(
  filename = "plots/muertes_personal_especializado.png",
  plot = p4,
  width = 10,
  height = 6,
  dpi = 300
)
