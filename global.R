library(shiny)
library(dplyr)
library(readr)
library(lubridate)
library(ggplot2)
library(leaflet)
library(DT)
library(janitor)
library(bslib)

# Paleta de colores 
chi_blue  <- "#41B6E6"
chi_red   <- "#E4002B"
chi_white <- "#FFFFFF"
chi_dark  <- "#111111"

# Datos
crimes_raw <- read_csv(
  "chicago_crime_2020-2025.csv",
  show_col_types = FALSE
)

crimes <- crimes_raw %>%
  clean_names() %>%                     
  mutate(
    date = mdy_hms(date, tz = "America/Chicago"),
    year = year(date),
    month = floor_date(date, "month"),
    weekday = wday(date, label = TRUE, abbr = TRUE, week_start = 1),
    hour = hour(date)
  )         


years_range  <- range(crimes$year, na.rm = TRUE)
primary_types <- sort(unique(crimes$primary_type))
districts     <- sort(unique(crimes$district))


chi_theme <- bs_theme(
  version = 5,
  base_font = font_google("Roboto"),
  fg = "#000000",
  bg = "#F5F5F5",
  primary = chi_blue,
  secondary = chi_red
)

theme_clean_white <- theme_minimal(base_family = "Roboto") +
  theme(
    text = element_text(color = "black"),
    axis.text = element_text(color = "black"),
    axis.title = element_text(color = "black"),
    plot.title = element_text(color = "black", face = "bold", size = 14),
    panel.grid.major = element_line(color = "#DDDDDD"),
    panel.grid.minor = element_blank(),
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA)
  )









