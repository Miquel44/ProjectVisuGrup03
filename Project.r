library(readr)
library(dplyr)
library(ggplot2)
library(tidyr)
library(tibble)

# Cargar el dataset
data <- read_csv("/Users/lianbaguebatlle/Desktop/Dades/Segon/2nsemestre/VisualitzacioDades/Projecte/casualties_daily.csv")
view(data)

data <- as_tibble(data)

# Formatear 'report_Date' como fecha
data <- data %>%
  mutate(report_date = as.Date(report_date))


# Dataset para visualizar cumulative killed, injured y masacres a lo largo del tiempo
df_killed_injured_cum <- data%>% select(report_date, ext_killed_cum, ext_injured_cum, ext_massacres_cum)
view(df_killed_injured_cum)

# Dataset para visualizar killed, injured a lo largo del tiempo (no acumulativo)
df_killed_injured_perday <- data%>% select(report_date, ext_killed, ext_injured)
view(df_killed_injured_perday)

# Dataset para estudio demografico (killed children, women and others)
df_demographics <- data %>% select(report_date, ext_killed_cum, ext_killed_children_cum, ext_killed_women_cum) %>% mutate(killed_other_cum = ext_killed_cum - ext_killed_children_cum - ext_killed_women_cum)
view(df_demographics)

# Dataset para visualizar muertes de personal medico, periodistas, emmergency services.
df_personnel <- data %>%select(report_date, ext_civdef_killed_cum, ext_press_killed_cum, ext_med_killed_cum )
view(df_personnel)

anyNA(df_killed_injured_cum)
anyNA(df_killed_injured_perday)
anyNA(df_demographics)
anyNA(df_personnel)

write_csv(df_killed_injured_cum, "/Users/lianbaguebatlle/Desktop/Dades/Segon/2nsemestre/VisualitzacioDades/Projecte/df_killed_injured_cum.csv")
write_csv(df_demographics, "/Users/lianbaguebatlle/Desktop/Dades/Segon/2nsemestre/VisualitzacioDades/Projecte/df_demographics.csv")

