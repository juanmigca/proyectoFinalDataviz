library(shiny)

shinyUI(
  fluidPage(
    theme = chi_theme,
    title = "Chicago Crime Dashboard",
    
    # Estilos 
    tags$head(
      tags$style(HTML("
        body {
          background-color: #FFFFFF !important;
          color: #000000 !important;
        }
        
        img {
          max-width: 100%;
          height: auto;
        }
    
        
        .chicago-header {
          background-color: #FFFFFF !important;
          padding: 10px 20px;
          border-bottom: 3px solid #000000; 
        }
    
        .chicago-title {
          color: #000000 !important;
          font-weight: 700;
          font-size: 26px;
          letter-spacing: 2px;
          text-transform: uppercase;
        }
    
        .chicago-subtitle {
          color: #333333 !important;
          font-size: 13px;
          text-transform: uppercase;
          letter-spacing: 1px;
        }
    
     
        .kpi-box {
          background-color: #FFFFFF;
          border-radius: 10px;
          border-left: 4px solid #000000; 
          padding: 12px 16px;
          margin-bottom: 15px;
          box-shadow: 0px 2px 4px rgba(0,0,0,0.15);
        }
    
        .kpi-label {
          font-size: 11px;
          text-transform: uppercase;
          color: #555555;
        }
    
        .kpi-value {
          font-size: 26px;
          font-weight: 700;
          color: #E4002B; /* rojo chicago */
        }
    
        .kpi-sub {
          font-size: 11px;
          color: #888888;
        }
    
        
        .nav-tabs > li > a {
          color: #000000 !important;
          background-color: #FFFFFF !important;
          border: 1px solid #CCCCCC;
        }
    
        .nav-tabs > li.active > a,
        .nav-tabs > li.active > a:focus,
        .nav-tabs > li.active > a:hover {
          background-color: #000000 !important; 
          color: #FFFFFF !important;
          border: 1px solid #000000 !important;
        }
    
        /* Paneles */
        .panel, .well, .container-fluid {
          background-color: #FFFFFF !important;
          color: #000000 !important;
        }
    
        /* Sidebar */
        .sidebarPanel {
          background-color: #FFFFFF !important;
          color: #000000 !important;
        }
    
        /* Inputs */
        label, .control-label {
          color: #000000 !important;
        }
    
        .form-control {
          background-color: #FFFFFF !important;
          color: #000000 !important;
          border: 1px solid #000000 !important;
        }
      "))
    ),
    
    # Encabezado
    div(
      class = "chicago-header",
      fluidRow(
        column(
          width = 3,
          align = "left",
          img(
            src = "cityofchicago.png",
            style = "max-height:60px; width:auto; max-width:100%;"
          )
        ),
        column(
          width = 6,
          align = "center",
          div(class = "chicago-title", "CHICAGO CRIME DASHBOARD"),
          div(
            class = "chicago-subtitle",
            "INCIDENTES REPORTADOS AL CHICAGO POLICE DEPARTMENT (2020–2025)"
          )
        ),
        column(
          width = 3,
          align = "right",
          img(
            src = "chicagopd.png",
            style = "max-height:60px; width:auto; max-width:100%;"
          )
        )
      )
    ),
    
    br(),
    
    # Layout 
    sidebarLayout(
      sidebarPanel(
        width = 3,
        h4("Filtros", style = "color:#FFFFFF;"),
        sliderInput(
          inputId = "year_range",
          label = "Años",
          min   = years_range[1],
          max   = years_range[2],
          value = years_range,
          sep   = ""
        ),
        selectInput(
          inputId = "primary_type",
          label = "Tipo de delito principal",
          choices  = c("Todos" = "__ALL__", primary_types),
          selected = "__ALL__",
          multiple = TRUE
        ),
        selectInput(
          inputId = "district",
          label = "Distrito policial",
          choices  = c("Todos" = "__ALL__", districts),
          selected = "__ALL__",
          multiple = TRUE
        ),
        checkboxInput(
          inputId = "only_arrest",
          label   = "Solo incidentes con arresto",
          value   = FALSE
        ),
        checkboxInput(
          inputId = "only_domestic",
          label   = "Solo incidentes de violencia doméstica",
          value   = FALSE
        ),
        hr(),
        helpText(
          "Los filtros se aplican en todas las visualizaciones de la página de exploración general."
        )
      ),
      
      mainPanel(
        width = 9,
        tabsetPanel(
          id = "main_tabs",
          
          # Página 1
          tabPanel(
            title = "Exploración general",
            
            br(),
            
            # KPIs
            uiOutput("kpi_boxes"),
            
            br(),
            
            # Gráficos
            fluidRow(
              column(
                width = 6,
                h4("Tendencia mensual de incidentes"),
                plotOutput("plot_monthly", height = "300px")
              ),
              column(
                width = 6,
                h4("Top 10 tipos de delito"),
                plotOutput("plot_top_types", height = "300px")
              )
            ),
            
            br(),
            
            fluidRow(
              column(
                width = 6,
                h4("Distribución por hora del día"),
                plotOutput("plot_hourly", height = "300px")
              ),
              column(
                width = 6,
                h4("Mapa de incidentes (muestra)"),
                leafletOutput("map_crime", height = "300px")
              )
            ),
            
            br(),
            h4("Detalle de incidentes filtrados"),
            DTOutput("table_crime")
          ),
          
          # Página 2
          tabPanel(
            title = "Análisis por distrito",
            br(),
            
            # Controles específicos de esta página
            fluidRow(
              column(
                width = 3,
                selectInput(
                  inputId = "district_focus",
                  label = "Seleccionar distrito para análisis",
                  choices = districts,
                  selected = districts[1]
                )
              ),
              column(
                width = 3,
                selectInput(
                  inputId = "compare_districts",
                  label = "Comparar con distrito(s)",
                  choices = districts,
                  selected = districts[2],
                  multiple = TRUE
                )
              ),
              column(
                width = 3,
                sliderInput(
                  inputId = "year_district",
                  label = "Año",
                  min = years_range[1],
                  max = years_range[2],
                  value = years_range[2],
                  sep = "",
                  step = 1
                )
              ),
              column(
                width = 3,
                selectInput(
                  inputId = "crime_category",
                  label = "Categoría de delito",
                  choices = c("Todos" = "__ALL__", primary_types),
                  selected = "__ALL__"
                )
              )
            ),
            
            hr(),
            
            # KPIs del distrito seleccionado
            uiOutput("kpi_district_boxes"),
            
            br(),
            
            # Primera fila de gráficos
            fluidRow(
              column(
                width = 6,
                h4("Comparativa de incidentes por distrito"),
                plotOutput("plot_district_comparison", height = "300px")
              ),
              column(
                width = 6,
                h4("Tendencia anual del distrito seleccionado"),
                plotOutput("plot_district_trend", height = "300px")
              )
            ),
            
            br(),
            
            # Segunda fila de gráficos
            fluidRow(
              column(
                width = 6,
                h4("Distribución por día de la semana"),
                plotOutput("plot_weekday_district", height = "300px")
              ),
              column(
                width = 6,
                h4("Top 5 tipos de delito en el distrito"),
                plotOutput("plot_top_crimes_district", height = "300px")
              )
            ),
            
            br(),
            
            # Tabla de resumen
            h4("Resumen detallado por tipo de delito en el distrito"),
            DTOutput("table_district_summary")
          )
        )
      )
    )
  )
)