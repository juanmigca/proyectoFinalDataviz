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
  
  
  # ----------------- TABLA -----------------
  
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
  
})

