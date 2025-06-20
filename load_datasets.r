# Load libraries
library(readr)
library(dplyr)
library(tidyr)
library(tibble)

# Load dataset
data <- read_csv("data/casualties_daily.csv")
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

context_daily <- read_csv("data/chronology_nodes_clean.csv")
context_2023 <- context_daily %>%
  filter(format(date, "%Y") == "2023") %>% drop_na(links)

context_2024 <- context_daily %>%
  filter(format(date, "%Y") == "2024") %>% drop_na(links)

data2024 <- data %>% 
  filter(format(report_date, "%Y") == "2024")

joined_data <- context_2024 %>%
  full_join(data2024, by = c("date" = "report_date"))
