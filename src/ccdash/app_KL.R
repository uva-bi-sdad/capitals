library(shinydashboard)
library(dashboardthemes)
library(dplyr)
library(readr)
library(leaflet)
library(sf)
library(plotly)

datafin <- read_rds("~/capitals/rivanna_data/financial/fin_final.Rds")


#
# USER INTERFACE ----------------------------------------------------------------------------------------------------
#

ui <- dashboardPage(
  
  dashboardHeader(title = "Community Capitals"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem(text = "Community Capitals", tabName = "capitals", icon = icon("")),
      menuItem(text = "Financial Capital", tabName = "financial", icon = icon("money-check-alt"),
               menuSubItem(text = "Commerce Index", tabName = "fin_commerce", icon = ""),
               menuSubItem(text = "Agriculture Index", tabName = "fin_agri", icon = ""),
               menuSubItem(text = "Economic Diversification Index", tabName = "fin_econ", icon = ""),
               menuSubItem(text = "Financial Well-Being Index", tabName = "fin_wb", icon = ""),
               menuSubItem(text = "Employment Index", tabName = "fin_employ", icon = "")
               ),
      
      menuItem(text = "Human Capital", tabName = "human", icon = icon("child")),
      menuItem(text = "Social Capital", tabName = "social", icon = icon("handshake")),
      menuItem(text = "Built Capital", tabName = "built", icon = icon("home")),
      menuItem(text = "Natural Capital", tabName = "natural", icon = icon("tree")),
      menuItem(text = "Political Capital", tabName = "political", icon = icon("balance-scale-left")),
      menuItem(text = "Cultural Capital", tabName = "cultural", icon = icon("landmark")),
      menuItem(text = "Data and Methods", tabName = "datamethods", icon = icon("")),
      menuItem(text = "Contact", tabName = "contact", icon = icon(""))
    )
  ),
  
  dashboardBody(
    tags$head(tags$style('.selectize-dropdown {z-index: 10000}')),
    
    shinyDashboardThemes(
      theme = "grey_light"
    ),
    
    tabItems(
      # SUMMARY CONTENT -------------------------
      tabItem(tabName = "capitals",
              fluidRow(
                box(title = "Community Capitals",
                    width = 12,
                    align = "center",
                    img(src = "capitals.png", class = "topimage", height = "20%", style = "display: block; margin-left: auto; margin-right: auto; border: 1px solid #B4B4B4")
                )
              ),
              
              fluidRow(
                infoBox("Financial Capital", icon = icon("money-check-alt"), color = "yellow",
                        value = tags$h5("Financial resources available to invest in community projects and economic development.")),
                infoBox("Human Capital", icon = icon("child"), color = "light-blue",
                        value = tags$h5("Community residents' capacities, skills, abilities.")),
                infoBox("Social Capital", icon = icon("handshake"), color = "yellow",
                        value = tags$h5("Connections, networks, and ties between people and organizations that facilitate action.")),
                infoBox("Built Capital", icon = icon("home"), color = "light-blue",
                        value = tags$h5("Facilities, services, and other physical community infrastructure.")),
                infoBox("Natural Capital", icon = icon("tree"), color = "yellow",
                        value = tags$h5("The quality and quantity of natural and environmental community resources.")),
                infoBox("Political Capital", icon = icon("balance-scale-left"), color = "light-blue",
                        value = tags$h5("Community ability to develop and enforce rules, regulations, and standards.")),
                infoBox("Cultural Capital", icon = icon("landmark"), color = "yellow",
                        value = tags$h5("Material goods, values and norms, and traditions of historical and cultural importance."))
              )
      ),
      
      # FINANCIAL CAPITAL CONTENT -------------------------
      tabItem(tabName = "fin_commerce",
              fluidRow(
                box(title = "About Financial Capital",
                    width = 9,
                    "Box content here", 
                    br(), 
                    "More content"
                ),
                box(title = "Select Your State",
                    width = 3,
                    selectInput("fin_whichstate", label = NULL,
                                choices = list("Iowa",
                                               "Oregon",
                                               "Virginia"), 
                                selected = "Iowa")
                )
              ),
              fluidRow(    
                box(title = "Commerce Index",
                    width = 12,
                    h5(strong("County-Level Map")),
                    leafletOutput("plot_fin_index_commerce")
                )
              ),
              fluidRow(
                  tabBox(title = "Commerce Index Indicators",
                         id = "tab_indexfin_co",
                         width = 12,
                         side = "right",
                         tabPanel(title = "Number of Businesses",
                                  fluidRow(
                                    h4(strong("Number of Businesses per 10,000 People"), align = "center"),
                                    column(
                                      width = 6,
                                      h5(strong("County-Level Map")),
                                      leafletOutput("plot_fin_co_bus")
                                    ),
                                    column(
                                      width = 6,
                                      h5(strong("Indicator Box Plot")),
                                      plotlyOutput("plotly_fin_co_bus")
                                    )
                                  )
                         ),
                         tabPanel(title = "Number of New Businesses",
                                  fluidRow(
                                    h4(strong("Number of New Businesses per 10,000 People"), align = "center"),
                                    column(
                                      width = 6,
                                      h5(strong("County-Level Map")),
                                      leafletOutput("plot_fin_co_newbus")
                                    ),
                                    column(
                                      width = 6,
                                      h5(strong("Indicator Box Plot")),
                                      plotlyOutput("plotly_fin_co_newbus")
                                    )
                                  )
                         )
                  )
              )
                
              # 
              # 
              #   
              #   
              #   
              #   tabBox(title = "Financial Capital Index",
              #          id = "tab_indexfin",
              #          width = 12,
              #          side = "right",
              #          tabPanel(title = "Commerce Index", 
              #                   h5(strong("County-Level Map")),
              #                   leafletOutput("plot_fin_index_commerce")
              #          ),
              #          tabPanel(title = "Agriculture Index", 
              #                   h5(strong("County-Level Map")),
              #                   leafletOutput("plot_fin_index_agri")
              #          ),
              #          tabPanel(title = "Economic Diversification Index", 
              #                   h5(strong("County-Level Map")),
              #                   leafletOutput("plot_fin_index_econdiv")
              #          ),
              #          tabPanel(title = "Financial Well-Being Index", 
              #                   h5(strong("County-Level Map")),
              #                   leafletOutput("plot_fin_index_finwell")
              #          ),
              #          tabPanel(title = "Employment Index", 
              #                   h5(strong("County-Level Map")),
              #                   leafletOutput("plot_fin_index_emp")
              #          )
              #   )
              #),
              # 
              # fluidRow(
              #   box(title = "Financial Capital Indicators",
              #       width = 12,
              #       conditionalPanel(condition = "input.tab_indexfin == 'Commerce Index'",
              #                        column(width = 2,
              #                               h5(strong("Commerce Index Indicators")),
              #                               br(),
              #                               selectInput("fin_whichind", label = NULL,
              #                                           choices = list("Number of businesses per 10,000 people",
              #                                                          "Number of new businesses per 10,000 people",
              #                                                          "Land value per acre",
              #                                                          "Percent county in agriculture acres",
              #                                                          "Net income per farm operation",
              #                                                          "Percent employed in agriculture, forestry, fishing and hunting, mining industry",
              #                                                          "HHI of employment by industry",
              #                                                          "HHI of payroll by industry",
              #                                                          "Gini Index of income inequality",
              #                                                          "Percent households with income below poverty level in last 12 months",
              #                                                          "Percent households receiving public assistance or SNAP",
              #                                                          "Percent households receiving supplemental security income",
              #                                                          "Median household income",
              #                                                          "Percent population over age 25 with less than a four year degree",
              #                                                          "Share of people with a credit bureau record who have any debt in collections",
              #                                                          "Unemployment rate before COVID",
              #                                                          "Unemployment rate during COVID",
              #                                                          "Percent commuting 30 minutes or longer",
              #                                                          "Percent working age population in labor force")
              #                               )
              #                        )
              #       ),

              #   )
              # )
      ),
      
      
      
      # HUMAN CAPITAL CONTENT -------------------------
      tabItem(tabName = "human",
              fluidRow(
                box()
              )
      ),
      
      # SOCIAL CAPITAL CONTENT -------------------------
      tabItem(tabName = "social",
              fluidRow(
                box()
              )
      ), 
      
      # BUILT CAPITAL CONTENT -------------------------
      tabItem(tabName = "built",
              fluidRow(
                box()
              )
      ),  
      
      # NATURAL CAPITAL CONTENT -------------------------
      tabItem(tabName = "natural",
              fluidRow(
                box()
              )
      ),  
      
      # POLITICAL CAPITAL CONTENT -------------------------
      tabItem(tabName = "political",
              fluidRow(
                box()
              )
      ),  
      
      # CULTURAL CAPITAL CONTENT -------------------------
      tabItem(tabName = "cultural",
              fluidRow(
                box()
              )
      ),
      
      # DATA AND METHODS CONTENT -------------------------
      tabItem(tabName = "datamethods",
              fluidRow(
                box()
              )
      ),
      
      # CONTACT CAPITAL CONTENT -------------------------
      tabItem(tabName = "contact",
              fluidRow(
                box()
              )
      )      
    )
  )
)


#
# SERVER ----------------------------------------------------------------------------------------------------
#

server <- function(input, output, session) {
  
  # Function for boxplots
  create_boxplot <- function(myvar, myvarlabel) {
    
    plot_ly(y = ~myvar, 
            x = myvarlabel,
            showlegend = FALSE,
            hoverinfo = "y",
            type = "box",
            name = "") %>% 
      layout(title = "",
             xaxis = list(title = "",
                          zeroline = FALSE),
             yaxis = list(title = "",
                          zeroline = FALSE,
                          hoverformat = ".2f"))
  }
  
  # Function for indicator maps
  create_indicator <- function(data, myvar, myvarlabel) {
    
    pal <- colorQuantile("Blues", domain = myvar, probs = seq(0, 1, length = 6), right = TRUE)
    
    labels <- lapply(
      paste("<strong>Area: </strong>",
            data$NAME.y,
            "<br />",
            "<strong>", myvarlabel, ": </strong>",
            round(myvar, 2)),
      htmltools::HTML
    )
    
    leaflet(data = data) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(fillColor = ~pal(myvar), 
                  fillOpacity = 0.7, 
                  stroke = TRUE, smoothFactor = 0.7, weight = 0.5, color = "#202020",
                  label = labels,
                  labelOptions = labelOptions(direction = "bottom",
                                              style = list(
                                                "font-size" = "12px",
                                                "border-color" = "rgba(0,0,0,0.5)",
                                                direction = "auto"
                                              ))) %>%
      addLegend("bottomleft",
                pal = pal,
                values =  ~(myvar),
                title = "Value by<br>Quintile Group",
                opacity = 0.7,
                labFormat = function(type, cuts, p) {
                  n = length(cuts)
                  paste0("[", round(cuts[-n], 2), " &ndash; ", round(cuts[-1], 2), ")")
                })
  }
  
  # Function for index maps
  create_index <- function(data, myvar, myvarlabel) {
    
    pal <- colorNumeric("Blues", domain = myvar)
    
    labels <- lapply(
      paste("<strong>Area: </strong>",
            data$NAME.y,
            "<br />",
            "<strong>", myvarlabel, ": </strong>",
            round(myvar, 2)),
      htmltools::HTML
    )
    
    leaflet(data = data) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(fillColor = ~pal(myvar), 
                  fillOpacity = 0.7, 
                  stroke = TRUE, smoothFactor = 0.7, weight = 0.5, color = "#202020",
                  label = labels,
                  labelOptions = labelOptions(direction = "bottom",
                                              style = list(
                                                "font-size" = "12px",
                                                "border-color" = "rgba(0,0,0,0.5)",
                                                direction = "auto"
                                              ))) %>%
      addLegend("bottomleft",
                pal = pal,
                values =  ~(myvar),
                title = "Index Value",
                opacity = 0.7)
  }
  
  # Switches
  fin_data <- reactive({ datafin %>% filter(state == input$fin_whichstate) })
  
  # Financial - Indicators - Boxplot
  output$plotly_fin_ind <- renderPlotly({
    
    data_var <- switch(input$fin_whichind,
                       "Number of businesses per 10,000 people" = fin_data()$fin_estper10k,
                       "Number of new businesses per 10,000 people" = fin_data()$fin_newestper10k,
                       "Percent county in agriculture acres" = fin_data()$fin_pctagacres,
                       "Land value per acre" = fin_data()$fin_landvalacre,
                       "Net income per farm operation" = fin_data()$fin_netincperfarm,
                       "Percent employed in agriculture, forestry, fishing and hunting, mining industry" = fin_data()$fin_pctemplagri,
                       "HHI of employment by industry" = fin_data()$fin_emphhi,
                       "HHI of payroll by industry" = fin_data()$fin_aphhi,
                       "Gini Index of income inequality" = fin_data()$fin_gini,
                       "Percent households with income below poverty level in last 12 months" = fin_data()$fin_pctinpov,
                       "Percent households receiving public assistance or SNAP" = fin_data()$fin_pctassist,
                       "Percent households receiving supplemental security income" = fin_data()$fin_pctssi,
                       "Median household income" = fin_data()$fin_medinc,
                       "Percent population over age 25 with less than a four year degree" = fin_data()$fin_pctlessba,
                       "Share of people with a credit bureau record who have any debt in collections" = fin_data()$fin_pctdebtcol,
                       "Unemployment rate before COVID" = fin_data()$fin_unempprecovid,
                       "Unemployment rate during COVID" = fin_data()$fin_unempcovid,
                       "Percent commuting 30 minutes or longer" = fin_data()$fin_pctcommute,
                       "Percent working age population in labor force" = fin_data()$fin_pctlabforce)
    
    var_label <- switch(input$fin_whichind,
                        "Number of businesses per 10,000 people" = "Number of businesses per 10,000 people",
                        "Number of new businesses per 10,000 people" = "Number of new businesses per 10,000 people",
                        "Percent county in agriculture acres" = "Percent county in agriculture acres",
                        "Land value per acre" = "Land value per acre",
                        "Net income per farm operation" = "Net income per farm operation",
                        "Percent employed in agriculture, forestry, fishing and hunting, mining industry" = "Percent employed in agriculture, forestry, fishing and hunting, mining industry",
                        "HHI of employment by industry" = "HHI of employment by industry",
                        "HHI of payroll by industry" = "HHI of payroll by industry",
                        "Gini Index of income inequality" = "Gini Index of income inequality",
                        "Percent households with income below poverty level in last 12 months" = "Percent households with income below poverty level in last 12 months",
                        "Percent households receiving public assistance or SNAP" = "Percent households receiving public assistance or SNAP",
                        "Percent households receiving supplemental security income" = "Percent households receiving supplemental security income",
                        "Median household income" = "Median household income",
                        "Percent population over age 25 with less than a four year degree" = "Percent population over age 25 with less than a four year degree",
                        "Share of people with a credit bureau record who have any debt in collections" = "Share of people with a credit bureau record who have any debt in collections",
                        "Unemployment rate before COVID" = "Unemployment rate before COVID",
                        "Unemployment rate during COVID" = "Unemployment rate during COVID",
                        "Percent commuting 30 minutes or longer" = "Percent commuting 30 minutes or longer",
                        "Percent working age population in labor force" = "Percent working age population in labor force")
    
    create_boxplot(data_var, var_label)
  })
  
  # Financial - Indicators - Map
  output$plot_fin_ind <- renderLeaflet({
    
    data_var <- switch(input$fin_whichind,
                       "Number of businesses per 10,000 people" = fin_data()$fin_estper10k,
                       "Number of new businesses per 10,000 people" = fin_data()$fin_newestper10k,
                       "Percent county in agriculture acres" = fin_data()$fin_pctagacres,
                       "Land value per acre" = fin_data()$fin_landvalacre,
                       "Net income per farm operation" = fin_data()$fin_netincperfarm,
                       "Percent employed in agriculture, forestry, fishing and hunting, mining industry" = fin_data()$fin_pctemplagri,
                       "HHI of employment by industry" = fin_data()$fin_emphhi,
                       "HHI of payroll by industry" = fin_data()$fin_aphhi,
                       "Gini Index of income inequality" = fin_data()$fin_gini,
                       "Percent households with income below poverty level in last 12 months" = fin_data()$fin_pctinpov,
                       "Percent households receiving public assistance or SNAP" = fin_data()$fin_pctassist,
                       "Percent households receiving supplemental security income" = fin_data()$fin_pctssi,
                       "Median household income" = fin_data()$fin_medinc,
                       "Percent population over age 25 with less than a four year degree" = fin_data()$fin_pctlessba,
                       "Share of people with a credit bureau record who have any debt in collections" = fin_data()$fin_pctdebtcol,
                       "Unemployment rate before COVID" = fin_data()$fin_unempprecovid,
                       "Unemployment rate during COVID" = fin_data()$fin_unempcovid,
                       "Percent commuting 30 minutes or longer" = fin_data()$fin_pctcommute,
                       "Percent working age population in labor force" = fin_data()$fin_pctlabforce)
    
    var_label <- switch(input$fin_whichind,
                        "Number of businesses per 10,000 people" = "Number of businesses per 10,000 people",
                        "Number of new businesses per 10,000 people" = "Number of new businesses per 10,000 people",
                        "Percent county in agriculture acres" = "Percent county in agriculture acres",
                        "Land value per acre" = "Land value per acre",
                        "Net income per farm operation" = "Net income per farm operation",
                        "Percent employed in agriculture, forestry, fishing and hunting, mining industry" = "Percent employed in agriculture, forestry, fishing and hunting, mining industry",
                        "HHI of employment by industry" = "HHI of employment by industry",
                        "HHI of payroll by industry" = "HHI of payroll by industry",
                        "Gini Index of income inequality" = "Gini Index of income inequality",
                        "Percent households with income below poverty level in last 12 months" = "Percent households with income below poverty level in last 12 months",
                        "Percent households receiving public assistance or SNAP" = "Percent households receiving public assistance or SNAP",
                        "Percent households receiving supplemental security income" = "Percent households receiving supplemental security income",
                        "Median household income" = "Median household income",
                        "Percent population over age 25 with less than a four year degree" = "Percent population over age 25 with less than a four year degree",
                        "Share of people with a credit bureau record who have any debt in collections" = "Share of people with a credit bureau record who have any debt in collections",
                        "Unemployment rate before COVID" = "Unemployment rate before COVID",
                        "Unemployment rate during COVID" = "Unemployment rate during COVID",
                        "Percent commuting 30 minutes or longer" = "Percent commuting 30 minutes or longer",
                        "Percent working age population in labor force" = "Percent working age population in labor force")
    
    create_indicator(fin_data(), data_var, var_label)
  })
  
  # Financial - Indicators - Index
  output$plot_fin_index_commerce <- renderLeaflet({
    create_index(fin_data(), fin_data()$fin_index_commerce, "Commerce Index")
  })
  
  output$plot_fin_index_agri <- renderLeaflet({
    create_index(fin_data(), fin_data()$fin_index_agri, "Agriculture Index")
  })
  
  output$plot_fin_index_econdiv <- renderLeaflet({
    create_index(fin_data(), fin_data()$fin_index_divers, "Economic Diversification Index")
  })
  
  output$plot_fin_index_finwell <- renderLeaflet({
    create_index(fin_data(), fin_data()$fin_index_well, "Financial Well-Being Index")
  })
  
  output$plot_fin_index_empl <- renderLeaflet({
    create_index(fin_data(), fin_data()$fin_index_empl, "Employment Index")
  })
  
  
  # Financial - Commerce Indicators - Boxplot and Map ------------------------------------
  
  output$plotly_fin_co_bus <- renderPlotly({
    
    data_var <- fin_data()$fin_estper10k
    var_label <- "Number of businesses per 10,000 people"
    
    create_boxplot(data_var, var_label)
  })

  
  output$plot_fin_co_bus <- renderLeaflet({
    
    data_var <- fin_data()$fin_estper10k
    var_label <- "Number of businesses per 10,000 people"
    
    create_indicator(fin_data(), data_var, var_label)
  })
  
  
  output$plotly_fin_co_newbus <- renderPlotly({
    
    data_var <- fin_data()$fin_newestper10k
    var_label <- "Number of new businesses per 10,000 people"
    
    create_boxplot(data_var, var_label)
  })
  
  
  output$plot_fin_co_newbus <- renderLeaflet({
    
    data_var <- fin_data()$fin_newestper10k
    var_label <- "Number of new businesses per 10,000 people"
    
    create_indicator(fin_data(), data_var, var_label)
  })
  
    
}


#
# APP ----------------------------------------------------------------------------------------------------
#

shinyApp(ui, server)