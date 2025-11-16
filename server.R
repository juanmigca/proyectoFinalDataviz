library(shiny)

shinyServer(function(input, output, session) {
  
  
  
  filtered_data <- reactive({
    df <- crimes %>%
      filter(
        year >= input$year_range[1],
        year <= input$year_range[2]
      )
    
    # Filtros
    if (!("__ALL__" %in% input$primary_type) && length(input$primary_type) > 0) {
      df <- df %>% filter(primary_type %in% input$primary_type)
    }
    
    if (!("__ALL__" %in% input$district) && length(input$district) > 0) {
      df <- df %>% filter(district %in% input$district)
    }
    
    if (isTRUE(input$only_arrest)) {
      df <- df %>% filter(arrest == TRUE)
    }
    
    if (isTRUE(input$only_domestic)) {
      df <- df %>% filter(domestic == TRUE)
    }
    
    df
  })
  
  # KPIs
  
  output$kpi_boxes <- renderUI({
    df <- filtered_data()
    
    total_incidents <- nrow(df)
    
    arrest_rate <- if (total_incidents > 0) {
      mean(df$arrest, na.rm = TRUE) * 100
    } else {
      NA_real_
    }
    
    domestic_rate <- if (total_incidents > 0) {
      mean(df$domestic, na.rm = TRUE) * 100
    } else {
      NA_real_
    }
    
    last_update <- crimes %>%
      summarise(last_upd = max(updated_on, na.rm = TRUE)) %>%
      pull(last_upd)
    
    fluidRow(
      column(
        width = 4,
        div(
          class = "kpi-box",
          div(class = "kpi-label", "Incidentes (filtro actual)"),
          div(
            class = "kpi-value",
            ifelse(
              is.finite(total_incidents),
              formatC(total_incidents, big.mark = ",", format = "d"),
              "0"
            )
          ),
          div(class = "kpi-sub", "Registros en el rango y filtros seleccionados")
        )
      ),
      column(
        width = 4,
        div(
          class = "kpi-box",
          div(class = "kpi-label", "Porcentaje con arresto"),
          div(
            class = "kpi-value",
            ifelse(
              is.finite(arrest_rate),
              paste0(round(arrest_rate, 1), "%"),
              "N/A"
            )
          ),
          div(class = "kpi-sub", "Porcentaje de incidentes donde hubo arresto")
        )
      ),
      column(
        width = 4,
        div(
          class = "kpi-box",
          div(class = "kpi-label", "Incidentes domésticos"),
          div(
            class = "kpi-value",
            ifelse(
              is.finite(domestic_rate),
              paste0(round(domestic_rate, 1), "%"),
              "N/A"
            )
          ),
          div(
            class = "kpi-sub",
            paste0(
              "Última actualización del dataset: ",
              if (!is.na(last_update)) as.character(last_update) else "N/D"
            )
          )
        )
      )
    )
  })
  
  #Tendencia mensual
  
  output$plot_monthly <- renderPlot({
    df <- filtered_data()
    
    if (nrow(df) == 0) {
      return(NULL)
    }
    
    monthly <- df %>%
      group_by(month) %>%
      summarise(n = n(), .groups = "drop")
    
    ggplot(monthly, aes(x = month, y = n)) +
      geom_line(color = chi_blue, size = 1) +
      geom_point(color = chi_red, size = 2) +
      labs(
        x = "Mes",
        y = "Número de incidentes"
      ) + 
      theme_clean_white
  })
  
  #Toip 10 delitos
  
  output$plot_top_types <- renderPlot({
    df <- filtered_data()
    
    if (nrow(df) == 0) {
      return(NULL)
    }
    
    top_types <- df %>%
      count(primary_type, sort = TRUE) %>%
      slice_head(n = 10) %>%
      mutate(primary_type = reorder(primary_type, n))
    
    ggplot(top_types, aes(x = n, y = primary_type)) +
      geom_col(fill = chi_red) +
      labs(
        x = "Número de incidentes",
        y = NULL
      ) + 
      theme_clean_white
  })
  
  # Distribución por hora
  
  output$plot_hourly <- renderPlot({
    df <- filtered_data()
    
    if (nrow(df) == 0) {
      return(NULL)
    }
    
    hourly <- df %>%
      count(hour)
    
    ggplot(hourly, aes(x = hour, y = n)) +
      geom_col(fill = chi_blue) +
      scale_x_continuous(breaks = 0:23) +
      labs(
        x = "Hora del día",
        y = "Número de incidentes"
      ) + 
      theme_clean_white
  })
  
  # Mapa
  
  output$map_crime <- renderLeaflet({
    
    df <- filtered_data() %>%
      filter(!is.na(latitude), !is.na(longitude))
    
    if (nrow(df) == 0) {
      return(leaflet() %>% addTiles())
    }
    
    # Muestra 
    set.seed(123123123)
    sample_n <- min(2000, nrow(df))  
    
    df_sample <- df %>% slice_sample(n = sample_n)
    
    leaflet(df_sample) %>%
      addTiles() %>%
      addCircleMarkers(
        lng = ~longitude,
        lat = ~latitude,
        radius = 3,
        stroke = FALSE,
        fillOpacity = 0.6,
        color = chi_red
      ) %>%
      setView(
        lng = mean(df_sample$longitude, na.rm = TRUE),
        lat = mean(df_sample$latitude, na.rm = TRUE),
        zoom = 10
      )
  })
  
  
  # Tabla
  
  output$table_crime <- renderDT({
    df <- filtered_data()
    
    if (nrow(df) == 0) {
      return(datatable(
        data.frame(Mensaje = "No hay registros que coincidan con los filtros seleccionados.")
      ))
    }
    
    df %>%
      select(
        date,
        primary_type,
        description,
        location_description,
        district,
        ward,
        community_area,
        arrest,
        domestic
      ) %>%
      datatable(
        options = list(
          pageLength = 10,
          scrollX = TRUE
        ),
        rownames = FALSE
      )
  })
  
  # Página 2
  
  # Datos filtrados para el análisis por distrito
  district_data <- reactive({
    df <- crimes %>%
      filter(year == input$year_district)
    
    if (input$crime_category != "__ALL__") {
      df <- df %>% filter(primary_type == input$crime_category)
    }
    
    df
  })
  
  # KPIs del distrito seleccionado
  output$kpi_district_boxes <- renderUI({
    df <- district_data() %>%
      filter(district == input$district_focus)
    
    total_district <- nrow(df)
    
    arrest_rate_district <- if (total_district > 0) {
      mean(df$arrest, na.rm = TRUE) * 100
    } else {
      NA_real_
    }
    
    most_common <- if (total_district > 0) {
      df %>%
        count(primary_type, sort = TRUE) %>%
        slice(1) %>%
        pull(primary_type)
    } else {
      "N/A"
    }
    
    fluidRow(
      column(
        width = 4,
        div(
          class = "kpi-box",
          div(class = "kpi-label", paste("Incidentes en Distrito", input$district_focus)),
          div(
            class = "kpi-value",
            formatC(total_district, big.mark = ",", format = "d")
          ),
          div(class = "kpi-sub", paste("En el año", input$year_district))
        )
      ),
      column(
        width = 4,
        div(
          class = "kpi-box",
          div(class = "kpi-label", "Tasa de arresto"),
          div(
            class = "kpi-value",
            ifelse(
              is.finite(arrest_rate_district),
              paste0(round(arrest_rate_district, 1), "%"),
              "N/A"
            )
          ),
          div(class = "kpi-sub", "Porcentaje de arrestos en el distrito")
        )
      ),
      column(
        width = 4,
        div(
          class = "kpi-box",
          div(class = "kpi-label", "Delito más común"),
          div(
            class = "kpi-value",
            style = "font-size: 18px;",
            most_common
          ),
          div(class = "kpi-sub", "Tipo de delito más frecuente")
        )
      )
    )
  })
  
  # Comparativa de incidentes por distrito
  output$plot_district_comparison <- renderPlot({
    df <- district_data()
    
    if (nrow(df) == 0) {
      return(NULL)
    }
    
    # Incluir distrito seleccionado y comparados
    districts_to_show <- c(input$district_focus, input$compare_districts)
    
    comparison <- df %>%
      filter(district %in% districts_to_show) %>%
      count(district) %>%
      mutate(
        district = factor(district),
        is_focus = district == input$district_focus
      ) %>%
      arrange(desc(n))
    
    ggplot(comparison, aes(x = reorder(district, n), y = n, fill = is_focus)) +
      geom_col() +
      scale_fill_manual(values = c("TRUE" = chi_red, "FALSE" = chi_blue)) +
      coord_flip() +
      labs(
        x = "Distrito",
        y = "Número de incidentes"
      ) +
      theme_clean_white +
      theme(legend.position = "none")
  })
  
  # Tendencia anual del distrito seleccionado
  output$plot_district_trend <- renderPlot({
    df <- crimes %>%
      filter(district == input$district_focus)
    
    if (input$crime_category != "__ALL__") {
      df <- df %>% filter(primary_type == input$crime_category)
    }
    
    if (nrow(df) == 0) {
      return(NULL)
    }
    
    trend <- df %>%
      group_by(year) %>%
      summarise(n = n(), .groups = "drop")
    
    ggplot(trend, aes(x = year, y = n)) +
      geom_line(color = chi_blue, size = 1.2) +
      geom_point(color = chi_red, size = 3) +
      scale_x_continuous(breaks = unique(trend$year)) +
      labs(
        x = "Año",
        y = "Número de incidentes"
      ) +
      theme_clean_white
  })
  
  # Distribución por día de la semana
  output$plot_weekday_district <- renderPlot({
    df <- district_data() %>%
      filter(district == input$district_focus)
    
    if (nrow(df) == 0) {
      return(NULL)
    }
    
    weekday_dist <- df %>%
      count(weekday) %>%
      mutate(weekday = factor(weekday, levels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")))
    
    ggplot(weekday_dist, aes(x = weekday, y = n)) +
      geom_col(fill = chi_blue) +
      labs(
        x = "Día de la semana",
        y = "Número de incidentes"
      ) +
      theme_clean_white
  })
  
  # Top 5 tipos de delito en el distrito
  output$plot_top_crimes_district <- renderPlot({
    df <- district_data() %>%
      filter(district == input$district_focus)
    
    if (nrow(df) == 0) {
      return(NULL)
    }
    
    top_crimes <- df %>%
      count(primary_type, sort = TRUE) %>%
      slice_head(n = 5) %>%
      mutate(primary_type = reorder(primary_type, n))
    
    ggplot(top_crimes, aes(x = n, y = primary_type)) +
      geom_col(fill = chi_red) +
      labs(
        x = "Número de incidentes",
        y = NULL
      ) +
      theme_clean_white
  })
  
  # Tabla de resumen detallado
  output$table_district_summary <- renderDT({
    df <- district_data() %>%
      filter(district == input$district_focus)
    
    if (nrow(df) == 0) {
      return(datatable(
        data.frame(Mensaje = "No hay registros para este distrito en el año seleccionado.")
      ))
    }
    
    summary_table <- df %>%
      group_by(primary_type) %>%
      summarise(
        Total_Incidentes = n(),
        Con_Arresto = sum(arrest, na.rm = TRUE),
        Tasa_Arresto = paste0(round(mean(arrest, na.rm = TRUE) * 100, 1), "%"),
        Domesticos = sum(domestic, na.rm = TRUE),
        Tasa_Domestico = paste0(round(mean(domestic, na.rm = TRUE) * 100, 1), "%"),
        .groups = "drop"
      ) %>%
      arrange(desc(Total_Incidentes))
    
    datatable(
      summary_table,
      colnames = c(
        "Tipo de Delito", 
        "Total", 
        "Con Arresto", 
        "% Arresto",
        "Domésticos",
        "% Doméstico"
      ),
      options = list(
        pageLength = 15,
        scrollX = TRUE
      ),
      rownames = FALSE
    )
  })
  
})