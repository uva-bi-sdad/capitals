library(shinydashboard)
library(dashboardthemes)
library(dplyr)
library(readr)
library(leaflet)
library(sf)
library(plotly)
library(shinyjs)
library(rintrojs)
library(shinyBS)
library(shinyWidgets)


datafin <- read_rds("data/fin_final.Rds")


#
# USER INTERFACE ----------------------------------------------------------------------------------------------------
#

ui <- dashboardPage(title = "EM Data Infrastructure",
  
  #dashboardHeader(title = "Community Capitals"),
  
  header = dashboardHeader(
    titleWidth='100%',
    title = span(
      tags$img(src="shen.jpg", width = '100%'), 
      column(12, class="title-box", 
             tags$h1(class="primary-title", style='margin-top:10px;', 'Economic Mobility Data Infrastructure') 
             #tags$h2(class="primary-subtitle", style='margin-top:10px;', 'Subtitle')
      )
    )
  ),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem(text = "Community Capitals", tabName = "capitals", icon = icon("")),
      menuItem(text = "Financial Capital", tabName = "financial", icon = icon("money-check-alt")),
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
    
    tags$style(type="text/css", "
/*    Move everything below the header */
               .content-wrapper {
               margin-top: 50px;
               }
               .content {
               padding-top: 60px;
               }
               /*    Format the title/subtitle text */
               .title-box {
               position: absolute;
               text-align: center;
               top: 50%;
               left: 50%;
               transform:translate(-50%, -50%);
               }
               @media (max-width: 590px) {
               .title-box {
               position: absolute;
               text-align: center;
               top: 10%;
               left: 10%;
               transform:translate(-5%, -5%);
               }
               }
               @media (max-width: 767px) {
               .primary-title {
               font-size: 1.1em;
               }
               .primary-subtitle {
               font-size: 1em;
               }
               }
               /*    Make the image taller */
               .main-header .logo {
               height: 125px;
               }
               /*    Override the default media-specific settings */
               @media (max-width: 5000px) {
               .main-header {
               padding: 0 0;
               position: relative;
               }
               .main-header .logo,
               .main-header .navbar {
               width: 100%;
               float: none;
               }
               .main-header .navbar {
               margin: 0;
               }
               .main-header .navbar-custom-menu {
               float: right;
               }
               }
               /*    Move the sidebar down */
               .main-sidebar {
               position: absolute;
               }
               .left-side, .main-sidebar {
               padding-top: 175px;
               }"
    ), 
    
    tags$head(tags$style('.selectize-dropdown {z-index: 10000}')),
    
    # https://stackoverflow.com/questions/37169039/direct-link-to-tabitem-with-r-shiny-dashboard/37170333
    tags$script(HTML("
        var openTab = function(tabName){
          $('a', $('.sidebar')).each(function() {
            if(this.getAttribute('data-value') == tabName) {
              this.click()
            };
          });
        }
      ")),
    
    shinyDashboardThemes(
      theme = "grey_light"
    ),
    
    useShinyjs(),
    introjsUI(),
    
    tabItems(

      # SUMMARY CONTENT -------------------------

      tabItem(tabName = "capitals",
              fluidRow(
                box(title = "Community Capitals",
                    width = 12,
                    align = "center",
                    img(src = "capitals.png", class = "topimage", width = "100%",
                        style = "display: block; margin-left: auto; margin-right: auto; border: 1px solid #B4B4B4")
                )
              ),
              
              fluidRow(
                # tags$div(href="#shiny-tab-financial", "data-toggle" = "tab",
                #         infoBox("Financial Capital", icon = icon("money-check-alt"), color = "yellow",
                #         value = tags$h5("Financial resources available to invest in community projects and economic development."))),
                infoBoxOutput("fin_ibox"),
                infoBoxOutput("hum_ibox"),
                infoBoxOutput("soc_ibox"),
                infoBoxOutput("built_ibox"),
                infoBoxOutput("nat_ibox"),
                infoBoxOutput("pol_ibox"),
                infoBoxOutput("cult_ibox")
              )
      ),
      
      #
      # FINANCIAL CAPITAL CONTENT -------------------------------------------------
      #
      
      tabItem(tabName = "financial",
            
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
                box(title = "Select Your Index",
                    width = 12,
                    
                    radioGroupButtons(
                      inputId = "finidx_choice", #label = "Make a choice :",
                      choices = c("COMMERCE", "AGRICULTURE", "ECONOMIC DIVERSIFICATION", 
                                  "FINANCIAL WELL-BEING", "EMPLOYMENT"),
                      justified = FALSE, status = "primary", individual = TRUE)
                    )
                    
                ),
              
              #
              #  COMMERCE PANEL ------------------------------------------
              #
              
              conditionalPanel("input.finidx_choice == 'COMMERCE'",
              
                fluidRow(
                  
                  box(title = "Commerce Index",
                      width = 12,
                      h5(strong("County-Level Map")),
                      leafletOutput("plot_fin_index_commerce")
                  )
                  
                ),
                fluidRow(
                  tabBox(title = "Commerce Measures",
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
              ),
               
              
              #
              # AGRICULTURE PANEL ------------------------------------------
              #
              
              conditionalPanel("input.finidx_choice == 'AGRICULTURE'",
                               
                               fluidRow(
                                 
                                 box(title = "Agriculture Index",
                                     width = 12,
                                     h5(strong("County-Level Map")),
                                     leafletOutput("plot_fin_index_agri")
                                 )
                                 
                               ),
                               # fluidRow(
                               #   tabBox(title = "Agriculture Measures",
                               #          id = "tab_indexfin_ag",
                               #          width = 12,
                               #          side = "right",
                               #          tabPanel(title = "Number of Businesses",
                               #                   fluidRow(
                               #                     h4(strong("Number of Businesses per 10,000 People"), align = "center"),
                               #                     column(
                               #                       width = 6,
                               #                       h5(strong("County-Level Map")),
                               #                       leafletOutput("plot_fin_co_bus")
                               #                     ),
                               #                     column(
                               #                       width = 6,
                               #                       h5(strong("Indicator Box Plot")),
                               #                       plotlyOutput("plotly_fin_co_bus")
                               #                     )
                               #                   )
                               #          ),
                               #          tabPanel(title = "Number of New Businesses",
                               #                   fluidRow(
                               #                     h4(strong("Number of New Businesses per 10,000 People"), align = "center"),
                               #                     column(
                               #                       width = 6,
                               #                       h5(strong("County-Level Map")),
                               #                       leafletOutput("plot_fin_co_newbus")
                               #                     ),
                               #                     column(
                               #                       width = 6,
                               #                       h5(strong("Indicator Box Plot")),
                               #                       plotlyOutput("plotly_fin_co_newbus")
                               #                     )
                               #                   )
                               #          )
                               #   )
                               #)
              )
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
  
  cbGreens <- c("#F7F7F7", "#D9F0D3", "#ACD39E", "#5AAE61", "#1B7837", "#FFEE99")
  
  # Function for indicator boxplots --------------------------
  create_boxplot <- function(data, myvar, myvarlabel) {
    
    group = as.factor(data$state)

    data %>%
      plot_ly() %>%
        add_trace(x = as.numeric(group),
                  y = ~myvar,
                  showlegend = FALSE,
                  hoverinfo = "y",
                  type = "box",
                  marker = list(symbol = "asterisk-open"),
                  name = "") %>%
        add_markers(x = ~jitter(as.numeric(group), amount = 0.1), y = ~myvar, color = ~irr2010,
                    marker = list(size = 6),
                    hoverinfo = "text",
                    text = ~paste0("Rurality Index: ", round(irr2010,2),
                                 "<br>County: ",county),
                    showlegend = FALSE) %>%
        colorbar(title = "Index of <br>Relative Rurality") %>%
        layout(title = "",
               xaxis = list(title = myvarlabel,
                            zeroline = FALSE,
                            showticklabels = FALSE),
               yaxis = list(title = "",
                            zeroline = FALSE,
                            hoverformat = ".2f"))

  }
  
  # Function for indicator maps ------------------------------------
  create_indicator <- function(data, myvar, myvarlabel) {
    
    pal <- colorQuantile(cbGreens[1:5], domain = myvar, probs = seq(0, 1, length = 6), 
                         na.color = cbGreens[6], right = TRUE)
    
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
                title = "Value",  #by<br>Quintile Group",
                opacity = 0.7,
                labFormat = function(type, cuts, p) {
                  n = length(cuts)
                  paste0("[", round(cuts[-n], 2), " &ndash; ", round(cuts[-1], 2), ")")
                })
  }
  
  # Function for index maps ---------------------------------------
  create_index <- function(data, myvar, myvarlabel) {
    
    pal <- colorNumeric(cbGreens[1:5], domain = myvar, na.color = cbGreens[6])
    
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
  

  #
  # Capital Index Maps ------------------------------------------------
  #
  
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
  
  #
  # Financial - Commerce Indicators - Boxplot and Map ------------------------------------
  #
  
  output$plotly_fin_co_bus <- renderPlotly({
    
    data_var <- fin_data()$fin_estper10k
    var_label <- "Number of businesses per 10,000 people"
    
    create_boxplot(fin_data(), data_var, var_label)
  })

  
  output$plot_fin_co_bus <- renderLeaflet({
    
    data_var <- fin_data()$fin_estper10k
    var_label <- "Number of businesses per 10,000 people"
    
    create_indicator(fin_data(), data_var, var_label)
  })
  
  
  output$plotly_fin_co_newbus <- renderPlotly({
    
    data_var <- fin_data()$fin_newestper10k
    var_label <- "Number of new businesses per 10,000 people"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_co_newbus <- renderLeaflet({
    
    data_var <- fin_data()$fin_newestper10k
    var_label <- "Number of new businesses per 10,000 people"
    
    create_indicator(fin_data(), data_var, var_label)
  })
  
  
  #
  # Financial - Agriculture Indicators - Boxplot and Map ------------------------------------
  #
  
  # output$plotly_fin_co_bus <- renderPlotly({
  #   
  #   data_var <- fin_data()$fin_estper10k
  #   var_label <- "Number of businesses per 10,000 people"
  #   
  #   create_boxplot(fin_data(), data_var, var_label)
  # })
  # 
  # 
  # output$plot_fin_co_bus <- renderLeaflet({
  #   
  #   data_var <- fin_data()$fin_estper10k
  #   var_label <- "Number of businesses per 10,000 people"
  #   
  #   create_indicator(fin_data(), data_var, var_label)
  # })
  # 
  # 
  # output$plotly_fin_co_newbus <- renderPlotly({
  #   
  #   data_var <- fin_data()$fin_newestper10k
  #   var_label <- "Number of new businesses per 10,000 people"
  #   
  #   create_boxplot(fin_data(), data_var, var_label)
  # })
  # 
  # 
  # output$plot_fin_co_newbus <- renderLeaflet({
  #   
  #   data_var <- fin_data()$fin_newestper10k
  #   var_label <- "Number of new businesses per 10,000 people"
  #   
  #   create_indicator(fin_data(), data_var, var_label)
  # })
  # 
  
  
  #
  # Home Page InfoBox outputs -------------------------------------------------
  # 
  
  output$fin_ibox <- renderInfoBox({
    infoBox(title = a("Financial Capital", onclick = "openTab('financial')", href="#"),
            icon = icon("money-check-alt"), color = "yellow",
            value = tags$h5("Financial resources available to invest in community projects and economic development.") 
    )
  })
  
  output$hum_ibox <- renderInfoBox({
    infoBox(title = a("Human Capital", onclick = "openTab('human')", href="#"),
            icon = icon("child"), color = "light-blue",
            value = tags$h5("Community residents' capacities, skills, abilities.")
    )
  })
  
  output$soc_ibox <- renderInfoBox({
    infoBox(title = a("Social Capital", onclick = "openTab('social')", href="#"),
            icon = icon("handshake"), color = "yellow",
            value = tags$h5("Connections, networks, and ties between people and organizations that facilitate action.")
    )
  })
  
  output$built_ibox <- renderInfoBox({
    infoBox(title = a("Built Capital", onclick = "openTab('built')", href="#"),
            icon = icon("home"), color = "light-blue",
            value = tags$h5("Facilities, services, and other physical community infrastructure.")
    )
  })

  output$nat_ibox <- renderInfoBox({
    infoBox(title = a("Natural Capital", onclick = "openTab('natural')", href="#"),
            icon = icon("tree"), color = "yellow",
            value = tags$h5("The quality and quantity of natural and environmental community resources.")
    )
  })
  
  output$pol_ibox <- renderInfoBox({
    infoBox(title = a("Political Capital", onclick = "openTab('political')", href="#"),
            icon = icon("balance-scale-left"), color = "light-blue",
            value = tags$h5("Community ability to develop and enforce rules, regulations, and standards.")
    )
  })
  
  output$cult_ibox <- renderInfoBox({
    infoBox(title = a("Cultural Capital", onclick = "openTab('cultural')", href="#"),
            icon = icon("landmark"), color = "yellow",
            value = tags$h5("Material goods, values and norms, and traditions of historical and cultural importance.")
    )
  })
    
  
}


#
# APP ----------------------------------------------------------------------------------------------------
#

shinyApp(ui, server)