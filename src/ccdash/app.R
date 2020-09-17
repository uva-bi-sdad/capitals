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
library(DT)
library(RColorBrewer)
library(stringr)

datafin <- read_rds("~/Git/capitals/rivanna_data/financial/fin_final.Rds")
datahum <- read_rds("~/Git/capitals/rivanna_data/human/hum_final.Rds")
datasoc <- read_rds("~/Git/capitals/rivanna_data/social/soc_final.Rds")
datanat <- read_rds("~/Git/capitals/rivanna_data/natural/nat_final.Rds")

measures <- read.csv("~/Git/capitals/rivanna_data/measures.csv")

cbGreens2 <- c("#B2521A", "#D47417", "#EB8E38", "#C0C0C4", "#C3B144", "#7F842C", "#4E5827")

css_fix <- "div.info.legend.leaflet-control br {clear: both;}"
html_fix <- as.character(htmltools::tags$style(type = "text/css", css_fix))



#
# USER INTERFACE ----------------------------------------------------------------------------------------------------
#

ui <- dashboardPage(title = "EM Data Infrastructure",
                    
                    dashboardHeader(
                      titleWidth='100%',
                      title = span(
                        tags$img(src = "header.jpg", width = '100%'), 
                        column(12, class = "title-box", 
                               tags$h1(class = "primary-title", 
                                       style = "font-size: 2.8em; 
                                                font-weight: bold; 
                                                text-shadow: -1px -1px 0 #DCDCDC,
                                                             1px -1px 0 #DCDCDC,
                                                             -1px 1px 0 #DCDCDC,
                                                             1px 1px 0 #DCDCDC;", 
                                       'Economic Mobility Data Infrastructure') 
                        )
                      )
                    ),
                    
                    dashboardSidebar(
                      img(src = "logo.png", height = 60, width = 235),
                      sidebarMenu(
                        menuItem(text = "Community Capitals", tabName = "capitals", icon = icon("")),
                        menuItem(text = "Financial Capital", tabName = "financial", icon = icon("money-check-alt")),
                        menuItem(text = "Human Capital", tabName = "human", icon = icon("child")),
                        menuItem(text = "Social Capital", tabName = "social", icon = icon("handshake")),
                        menuItem(text = "Natural Capital", tabName = "natural", icon = icon("tree")),
                        menuItem(text = "Built Capital", tabName = "built", icon = icon("home")),
                        menuItem(text = "Political Capital", tabName = "political", icon = icon("balance-scale-left")),
                        menuItem(text = "Cultural Capital", tabName = "cultural", icon = icon("landmark")),
                        menuItem(text = "Data and Methods", tabName = "datamethods", icon = icon("")),
                        menuItem(text = "Contact", tabName = "contact", icon = icon(""))
                      )
                    ),
                    
                    dashboardBody(
                      HTML(html_fix),
                                  
                                  tags$head(tags$style('.selectize-dropdown {z-index: 10000}')),
                                  
                                  # http://jonkatz2.github.io/2018/06/22/Image-In-Shinydashboard-Header
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
               align: center;
               display: block;
               margin:0!important;
               padding:0!important;
               border:0!important;
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
                                              box(width = 4,
                                                  align = "left",
                                                  title = "Economic Mobility Data Infrastructure",
                                                  "We are leveraging the the Community Capitals framework used throughout the Cooperative Extension System network to better understand rural places. 
                                                  This framework is a strength-based approach to community change and resilience based on identifying and investing community resources, called assets, 
                                                  to grow capitals in seven key areas: financial, human, social, political, cultural, built, and natural.",
                                                  br(""),
                                                  "Our work extends this Community Capitals Framework by infusing the seven capitals with a data science core. 
                                                  This approach supports a quantitative assessment of each capital across multiple locales to promote economic mobility 
                                                  and drive community success.",
                                                  br(""),
                                                  img(src = "framework.png", class = "topimage", width = "100%",
                                                      style = "display: block; margin-left: auto; margin-right: auto; border: 0.5px solid #B4B4B4")
                                              ),
                                              
                                              box(width = 8,
                                                  title = "Community Capitals",
                                                  infoBoxOutput("fin_ibox", width = NULL), p(),
                                                  infoBoxOutput("hum_ibox", width = NULL), p(),
                                                  infoBoxOutput("soc_ibox", width = NULL), p(),
                                                  infoBoxOutput("nat_ibox", width = NULL), p(),
                                                  infoBoxOutput("built_ibox", width = NULL), p(),
                                                  infoBoxOutput("pol_ibox", width = NULL), p(),
                                                  infoBoxOutput("cult_ibox", width = NULL)
                                              )
                                            )
                                    ),
                                    
                                    #
                                    # FINANCIAL CAPITAL CONTENT -------------------------------------------------
                                    #
                                    
                                    tabItem(tabName = "financial",
                                            
                                            fluidRow(
                                              box(title = "About Financial Capital",
                                                  width = 9,
                                                  "Financial capital refers to the economic features of the community such as debt capital, 
                    investment capital, savings, tax revenue, tax abatements, and grants, as well as entrepreneurship,
                    persistent poverty, industry concentration, and philanthropy."
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
                                                    justified = FALSE, status = "success", individual = TRUE)
                                              )
                                              
                                            ),
                                            
                                            #
                                            # COMMERCE PANEL ------------------------------------------
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
                                                             fluidRow(
                                                               tabBox(title = "Agriculture Measures",
                                                                      id = "tab_indexfin_ag",
                                                                      width = 12,
                                                                      side = "right",
                                                                      tabPanel(title = "Agriculture Acres",
                                                                               fluidRow(
                                                                                 h4(strong("Percent County in Agriculture Acres"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_fin_ag_acres")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_fin_ag_acres")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Land Value",
                                                                               fluidRow(
                                                                                 h4(strong("Land Value Per Acre"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_fin_ag_landval")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_fin_ag_landval")
                                                                                 )
                                                                               )
                                                                      ), 
                                                                      tabPanel(title = "Net Income",
                                                                               fluidRow(
                                                                                 h4(strong("Net Income Per Farm Operation"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_fin_ag_netin")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_fin_ag_netin")
                                                                                 )
                                                                               )
                                                                      ), 
                                                                      tabPanel(title = "Percent Employed",
                                                                               fluidRow(
                                                                                 h4(strong("Percent Employed in Agriculture, Forestry, Fishing and Hunting, Mining Industry"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_fin_ag_employ")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_fin_ag_employ")
                                                                                 )
                                                                               )
                                                                      )
                                                               )
                                                             )
                                            ),
                                            
                                            
                                            #
                                            # ECONOMIC DIVERSIFICATION PANEL ------------------------------------------
                                            #
                                            
                                            conditionalPanel("input.finidx_choice == 'ECONOMIC DIVERSIFICATION'",
                                                             
                                                             fluidRow(
                                                               
                                                               box(title = "Economic Diversificiation Index",
                                                                   width = 12,
                                                                   h5(strong("County-Level Map")),
                                                                   leafletOutput("plot_fin_index_econdiv")
                                                               )
                                                               
                                                             ),
                                                             
                                                             fluidRow(
                                                               tabBox(title = "Economic Diversification Measures",
                                                                      id = "tab_indexfin_econdiv",
                                                                      width = 12,
                                                                      side = "right",
                                                                      tabPanel(title = "Herfindahl-Hirschman Index of Employment",
                                                                               fluidRow(
                                                                                 h4(strong("Herfindahl-Hirschman Index of Employment by Industry"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_fin_econdiv_emphhi")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_fin_econdiv_emphhi")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Herfindahl-Hirschman Index of Payroll",
                                                                               fluidRow(
                                                                                 h4(strong("Herfindahl-Hirschman Index of Payroll by Industry"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_fin_econdiv_payhhi")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_fin_econdiv_payhhi")
                                                                                 )
                                                                               )
                                                                      )
                                                                      
                                                               )
                                                             )
                                            ),
                                            
                                            #
                                            # FINANCIAL WELL-BEING PANEL ------------------------------------------
                                            #
                                            
                                            conditionalPanel("input.finidx_choice == 'FINANCIAL WELL-BEING'",
                                                             
                                                             fluidRow(
                                                               
                                                               box(title = "Financial Well-Being Index",
                                                                   width = 12,
                                                                   h5(strong("County-Level Map")),
                                                                   leafletOutput("plot_fin_index_finwell")
                                                               )
                                                               
                                                             ),
                                                             
                                                             fluidRow(
                                                               tabBox(title = "Financial Well-Being Measures",
                                                                      id = "tab_indexfin_finwell",
                                                                      width = 12,
                                                                      side = "right",
                                                                      tabPanel(title = "Gini Index",
                                                                               fluidRow(
                                                                                 h4(strong("Gini Index of Income Inequality"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_fin_finwell_gini")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_fin_finwell_gini")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Poverty Level",
                                                                               fluidRow(
                                                                                 h4(strong("Percent with Income Below Poverty Level in Last 12 Months"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_fin_finwell_pov")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_fin_finwell_pov")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Public Assistance/SNAP",
                                                                               fluidRow(
                                                                                 h4(strong("Percent Households Receiving Public Assistance or SNAP"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_fin_finwell_assist")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_fin_finwell_assist")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Supplemental Security Income",
                                                                               fluidRow(
                                                                                 h4(strong("Percent Households Receiving Supplemental Security Income"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_fin_finwell_ssi")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_fin_finwell_ssi")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Median Household Income",
                                                                               fluidRow(
                                                                                 h4(strong("Median Household Income"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_fin_finwell_medinc")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_fin_finwell_medinc")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Four Year Degree",
                                                                               fluidRow(
                                                                                 h4(strong("Percent of People Older than 25 with Less than a Four Year Degree"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_fin_finwell_lessba")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_fin_finwell_lessba")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Debt in Collection",
                                                                               fluidRow(
                                                                                 h4(strong("Share of People with a Credit Bureau Record Who Have Any Debt in Collections"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_fin_finwell_debtcol")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_fin_finwell_debtcol")
                                                                                 )
                                                                               )
                                                                      )
                                                                      
                                                                      
                                                               )
                                                             )
                                            ),
                                            #
                                            # EMPLOYMENT ------------------------------------------
                                            #
                                            
                                            conditionalPanel("input.finidx_choice == 'EMPLOYMENT'",
                                                             
                                                             fluidRow(
                                                               
                                                               box(title = "Employment Index",
                                                                   width = 12,
                                                                   h5(strong("County-Level Map")),
                                                                   leafletOutput("plot_fin_index_empl")
                                                               )
                                                               
                                                             ),
                                                             
                                                             fluidRow(
                                                               tabBox(title = "Employment Measures",
                                                                      id = "tab_indexfin_employ",
                                                                      width = 12,
                                                                      side = "right",
                                                                      tabPanel(title = "Unemployment Rate Before COVID",
                                                                               fluidRow(
                                                                                 h4(strong("Unemployment Rate Before COVID"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_fin_employ_unempprecovid")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_fin_employ_unempprecovid")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Unemployment Rate During COVID",
                                                                               fluidRow(
                                                                                 h4(strong("Unemployment Rate During COVID"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_fin_employ_unempcovid")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_fin_employ_unempcovid")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Commuting 30min+",
                                                                               fluidRow(
                                                                                 h4(strong("Percent Commuting 30min+"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_fin_employ_commute")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_fin_employ_commute")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Labor Force",
                                                                               fluidRow(
                                                                                 h4(strong("Percent of Working Age Population in Labor Force"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_fin_employ_labforce")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_fin_employ_labforce")
                                                                                 )
                                                                               )
                                                                      )
                                                                      
                                                               )
                                                             )
                                            )
                                            
                                            
                                    ),
                                    
                                    
                                    
                                    # HUMAN CAPITAL CONTENT -------------------------
                                    tabItem(tabName = "human",
                                            
                                            fluidRow(
                                              box(title = "About Human Capital",
                                                  width = 9,
                                                  "Human capital refers to the knowledge, skills, education, credentials, physical health, mental health, 
                    and other acquired or inherited traits essential for an optimal quality of life."
                                              ),
                                              box(title = "Select Your State",
                                                  width = 3,
                                                  selectInput("hum_whichstate", label = NULL,
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
                                                    inputId = "humidx_choice", #label = "Make a choice :",
                                                    choices = c("HEALTH", "EDUCATION", "CHILD CARE", 
                                                                "DESPAIR"),
                                                    justified = FALSE, status = "success", individual = TRUE)
                                              )
                                              
                                            ),
                                            #
                                            # HEALTH PANEL ------------------------------------------
                                            #
                                            
                                            conditionalPanel("input.humidx_choice == 'HEALTH'",
                                                             
                                                             fluidRow(
                                                               
                                                               box(title = "Health Index",
                                                                   width = 12,
                                                                   h5(strong("County-Level Map")),
                                                                   leafletOutput("plot_hum_index_health")
                                                               )
                                                               
                                                             ),
                                                             fluidRow(
                                                               tabBox(title = "Health Measures",
                                                                      id = "tab_indexhum_health",
                                                                      width = 12,
                                                                      side = "right",
                                                                      tabPanel(title = "Physical Health",
                                                                               fluidRow(
                                                                                 h4(strong("Average Number of Reported Poor Physical Health Days in a Month"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_hum_health_poorphys")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_hum_health_poorphys")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Mental Health",
                                                                               fluidRow(
                                                                                 h4(strong("Average Number of Reported Poor Mental Health Days in a Month"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_hum_health_poorment")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_hum_health_poorment")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Physical Activity",
                                                                               fluidRow(
                                                                                 h4(strong("Percentage of Adults that Report No Leisure-time Physical Activity"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_hum_health_nophys")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_hum_health_nophys")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Primary Care Physicians",
                                                                               fluidRow(
                                                                                 h4(strong("Primary Care Physicians per 100,000 Population"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_hum_health_primcare")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_hum_health_primcare")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Mental Health Providers",
                                                                               fluidRow(
                                                                                 h4(strong("Mental Health Providers per 100,000 Population"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_hum_health_menthealthprov")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_hum_health_menthealthprov")
                                                                                 )
                                                                               )
                                                                      )
                                                                      
                                                                      
                                                                      
                                                               )
                                                             )
                                            ),
                                            #
                                            # EDUCATION PANEL ------------------------------------------
                                            #
                                            
                                            conditionalPanel("input.humidx_choice == 'EDUCATION'",
                                                             
                                                             fluidRow(
                                                               
                                                               box(title = "Education Index",
                                                                   width = 12,
                                                                   h5(strong("County-Level Map")),
                                                                   leafletOutput("plot_hum_index_edu")
                                                               )
                                                               
                                                             ),
                                                             fluidRow(
                                                               tabBox(title = "Education Measures",
                                                                      id = "tab_indexhum_edu",
                                                                      width = 12,
                                                                      side = "right",
                                                                      tabPanel(title = "High School",
                                                                               fluidRow(
                                                                                 h4(strong("Percent of Population with At Least a High School Degree"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_hum_edu_hs")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_hum_edu_hs")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Reading Proficiency",
                                                                               fluidRow(
                                                                                 h4(strong("Reading Proficiency"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_hum_edu_read")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_hum_edu_read")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Math Proficiency",
                                                                               fluidRow(
                                                                                 h4(strong("Math Proficiency"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_hum_edu_math")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_hum_edu_math")
                                                                                 )
                                                                               )
                                                                      )
                                                               )
                                                             )
                                            ),
                                            #
                                            # CHILD CARE PANEL ------------------------------------------
                                            #
                                            
                                            conditionalPanel("input.humidx_choice == 'CHILD CARE'",
                                                             
                                                             fluidRow(
                                                               
                                                               box(title = "Child Care Index",
                                                                   width = 12,
                                                                   h5(strong("County-Level Map")),
                                                                   leafletOutput("plot_hum_index_childcare")
                                                               )
                                                               
                                                             ),
                                                             fluidRow(
                                                               tabBox(title = "Child Care Measures",
                                                                      id = "tab_indexhum_childcare",
                                                                      width = 12,
                                                                      side = "right",
                                                                      tabPanel(title = "Women to Men Pay Ratio",
                                                                               fluidRow(
                                                                                 h4(strong("Women to Men Pay Ratio"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_hum_childcare_payratio")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_hum_childcare_payratio")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Single-Parent Households",
                                                                               fluidRow(
                                                                                 h4(strong("Percent of Children Living in a Single-Parent Household"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_hum_childcare_singpar")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_hum_childcare_singpar")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Women Without a HS Diploma or Equivalent",
                                                                               fluidRow(
                                                                                 h4(strong("Percent of Women Who did not Receive HS Diploma or Equivalent"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_hum_childcare_womenhs")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_hum_childcare_womenhs")
                                                                                 )
                                                                               )
                                                                      )
                                                               )
                                                             )
                                            ),
                                            
                                            #
                                            # DESPAIR PANEL ------------------------------------------
                                            #
                                            
                                            conditionalPanel("input.humidx_choice == 'DESPAIR'",
                                                             
                                                             fluidRow(
                                                               
                                                               box(title = "Despair Index",
                                                                   width = 12,
                                                                   h5(strong("County-Level Map")),
                                                                   leafletOutput("plot_hum_index_despair")
                                                               )
                                                               
                                                             ),
                                                             fluidRow(
                                                               tabBox(title = "Despair Measures",
                                                                      id = "tab_indexhum_despair",
                                                                      width = 12,
                                                                      side = "right",
                                                                      tabPanel(title = "Divorce/Separation",
                                                                               fluidRow(
                                                                                 h4(strong("Percent Divorced or Separated"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_hum_despair_divorce")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_hum_despair_divorce")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Unemployed Population in Labor Force",
                                                                               fluidRow(
                                                                                 h4(strong("Percent Population in Labor Force Unemployed"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_hum_despair_unemp")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_hum_despair_unemp")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "White Men with High School Education or Lower",
                                                                               fluidRow(
                                                                                 h4(strong("Percent White Men with High School Education or Lower"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_hum_despair_whitemhs")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_hum_despair_whitemhs")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Rate of Alcohol, Overdose, and Suicide Deaths",
                                                                               fluidRow(
                                                                                 h4(strong("Age-adjusted Rate of Alcohol, Overdose, and Suicide Deaths Over 9 Years per 100,000 Population"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_hum_despair_aggdeaths")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_hum_despair_aggdeaths")
                                                                                 )
                                                                               )
                                                                      )
                                                               )
                                                             )
                                            )
                                            
                                            
                                            
                                            
                                    ),
                                    
                                    # SOCIAL CAPITAL CONTENT -------------------------
                                    
                                    
                                    tabItem(tabName = "social",
                                            
                                            fluidRow(
                                              box(title = "About Social Capital",
                                                  width = 9,
                                                  "Social capital refers to the resources, information, and support that communities can access through the bonds 
                    among members of the community and their families promoting mutual trust, reciprocity, collective 
                    identity, and a sense of a shared future."
                                              ),
                                              box(title = "Select Your State",
                                                  width = 3,
                                                  selectInput("soc_whichstate", label = NULL,
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
                                                    inputId = "socidx_choice", #label = "Make a choice :",
                                                    choices = c("SOCIAL ENGAGEMENT", "SOCIAL RELATIONSHIPS", "ISOLATION"),
                                                    justified = FALSE, status = "success", individual = TRUE)
                                              )
                                              
                                            ),
                                            
                                            #
                                            # SOCIAL ENGAGEMENT PANEL ------------------------------------------
                                            #
                                            
                                            conditionalPanel("input.socidx_choice == 'SOCIAL ENGAGEMENT'",
                                                             
                                                             fluidRow(
                                                               
                                                               box(title = "Social Engagment Index",
                                                                   width = 12,
                                                                   h5(strong("County-Level Map")),
                                                                   leafletOutput("plot_soc_index_socengage")
                                                               )
                                                               
                                                             ),
                                                             fluidRow(
                                                               tabBox(title = "Social Engagement Measures",
                                                                      id = "tab_indexsoc_eng",
                                                                      width = 12,
                                                                      side = "right",
                                                                      tabPanel(title = "Census Response Rate",
                                                                               fluidRow(
                                                                                 h4(strong("Census 2020 Mail and Online Self Response Rate"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_soc_eng_census")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_soc_eng_census")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Election Turnout",
                                                                               fluidRow(
                                                                                 h4(strong("Presidential Election 2016 Voter Turnout"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_soc_eng_turnout")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_soc_eng_turnout")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Civic Associations and Establishments",
                                                                               fluidRow(
                                                                                 h4(strong("Number of Civic Associations and Establishments per 1,000 Population"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_soc_eng_civic")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_soc_eng_civic")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Non-Profit Organizations",
                                                                               fluidRow(
                                                                                 h4(strong("Number of Non-Profit Organizations Including those with an International Approach"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_soc_eng_nonprof")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_soc_eng_nonprof")
                                                                                 )
                                                                               )
                                                                      )
                                                                      
                                                               )
                                                             )
                                            ),
                                            #
                                            # SOCIAL RELATIONSHIPS PANEL ------------------------------------------
                                            #
                                            
                                            conditionalPanel("input.socidx_choice == 'SOCIAL RELATIONSHIPS'",
                                                             
                                                             fluidRow(
                                                               
                                                               box(title = "Social Relationships Index",
                                                                   width = 12,
                                                                   h5(strong("County-Level Map")),
                                                                   leafletOutput("plot_soc_index_relationships")
                                                               )
                                                               
                                                             ),
                                                             fluidRow(
                                                               tabBox(title = "Social Relationships Measures",
                                                                      id = "tab_indexsoc_rel",
                                                                      width = 12,
                                                                      side = "right",
                                                                      tabPanel(title = "Juvenile Arrests",
                                                                               fluidRow(
                                                                                 h4(strong("Number of Juvenile Arrests per 1000 Juveniles"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_soc_rel_juvarrests")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_soc_rel_juvarrests")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Violent Crimes",
                                                                               fluidRow(
                                                                                 h4(strong("Number of Violent Crimes per 100,000 Population"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_soc_rel_violentcrimes")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_soc_rel_violentcrimes")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Grandparent Householders Responsible for Grandchildren",
                                                                               fluidRow(
                                                                                 h4(strong("Percent Grandparent Householders Responsible for Own Grandchildren"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_soc_rel_grandparent")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_soc_rel_grandparent")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Homeowners",
                                                                               fluidRow(
                                                                                 h4(strong("Percent Homeowners"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_soc_rel_homeown")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_soc_rel_homeown")
                                                                                 )
                                                                               )
                                                                      ), 
                                                                      tabPanel(title = "Living in the Same House as One Year Prior",
                                                                               fluidRow(
                                                                                 h4(strong("Percent Population Living in the Same House that They Lived in One Year Prior"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_soc_rel_samehouse")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_soc_rel_samehouse")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Households with Nonrelatives Present",
                                                                               fluidRow(
                                                                                 h4(strong("Percent Households with Nonrelatives Present"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_soc_rel_nonrel")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_soc_rel_nonrel")
                                                                                 )
                                                                               )
                                                                      )
                                                                      
                                                               )
                                                             )
                                            ),
                                            # ISOLATION PANEL ------------------------------------------
                                            #
                                            
                                            conditionalPanel("input.socidx_choice == 'ISOLATION'",
                                                             
                                                             fluidRow(
                                                               
                                                               box(title = "Isolation Index",
                                                                   width = 12,
                                                                   h5(strong("County-Level Map")),
                                                                   leafletOutput("plot_soc_index_isolation")
                                                               )
                                                               
                                                             ),
                                                             fluidRow(
                                                               tabBox(title = "Social Relationships Measures",
                                                                      id = "tab_indexsoc_iso",
                                                                      width = 12,
                                                                      side = "right",
                                                                      tabPanel(title = "Computing Devices",
                                                                               fluidRow(
                                                                                 h4(strong("Percent Households with a Computing Device (Computer or Smartphone)"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_soc_iso_comp")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_soc_iso_comp")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Commute",
                                                                               fluidRow(
                                                                                 h4(strong("Percent Workers with More than an Hour of Commute by Themselves"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_soc_iso_commute")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_soc_iso_commute")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Spoken English Proficiency",
                                                                               fluidRow(
                                                                                 h4(strong("Percent of Residents That Are Not Proficient in Speaking English"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_soc_iso_english")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_soc_iso_english")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Residents Who are 65+ and Live Alone",
                                                                               fluidRow(
                                                                                 h4(strong("Percent of All County Residents Who are Both Over 65 and Live Alone"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_soc_iso_65alone")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_soc_iso_65alone")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Poor Mental Health Days",
                                                                               fluidRow(
                                                                                 h4(strong("Percent of People Who Indicated That They Have More Than 14 Poor Mental Health Days per Month (Frequent Mental Distress)"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_soc_iso_mentalhealth")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_soc_iso_mentalhealth")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Suicide Rate",
                                                                               fluidRow(
                                                                                 h4(strong("Number of Suicides per 1,000 Population"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_soc_iso_suicide")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_soc_iso_suicide")
                                                                                 )
                                                                               )
                                                                      )
                                                                      
                                                               )
                                                             )
                                            )
                                    ),        
                                    
                                    # BUILT CAPITAL CONTENT -------------------------
                                    tabItem(tabName = "built",
                                            fluidRow(
                                              box(title = "About Built Capital",
                                                  width = 9,
                                                  "Built capital refers to the physical infrastructure that facilitates community activities such as 
                                                  broadband and other information technologies, utilities, water/sewer systems, roads and bridges, 
                                                  business parks, hospitals, main street buildings, playgrounds, and housing stock."
                                              ),
                                              box(title = "Select Your State",
                                                  width = 3,
                                                  selectInput("nat_whichstate", label = NULL,
                                                              choices = list("Iowa",
                                                                             "Oregon",
                                                                             "Virginia"), 
                                                              selected = "Iowa")
                                              )
                                            ),
                                            fluidRow(
                                              box(
                                                "COMING SOON."
                                              )
                                            )
                                    ),  
                                    
                                    # NATURAL CAPITAL CONTENT -------------------------
                                    tabItem(tabName = "natural",
                                            
                                            fluidRow(
                                              box(title = "About Natural Capital",
                                                  width = 9,
                                                  "Natural capital refers to the stock of natural or environmental ecosystem assets that provides a flow of useful goods or services to create possibilities 
                    (and limits) to community development such as air, water, soil, biodiversity, and weather."
                                              ),
                                              box(title = "Select Your State",
                                                  width = 3,
                                                  selectInput("nat_whichstate", label = NULL,
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
                                                    inputId = "natidx_choice", #label = "Make a choice :",
                                                    choices = c("QUANTITY OF RESOURCES", "QUALITY OF RESOURCES"),
                                                    justified = FALSE, status = "success", individual = TRUE)
                                              )
                                              
                                            ),
                                            #
                                            # QUANTITY OF RESOURCES PANEL ------------------------------------------
                                            #
                                            
                                            conditionalPanel("input.natidx_choice == 'QUANTITY OF RESOURCES'",
                                                             
                                                             fluidRow(
                                                               
                                                               box(title = "Quantity of Resources Index",
                                                                   width = 12,
                                                                   h5(strong("County-Level Map")),
                                                                   leafletOutput("plot_nat_index_quantres")
                                                               )
                                                               
                                                             ),
                                                             fluidRow(
                                                               tabBox(title = "Quantity of Resources Measures",
                                                                      id = "tab_indexnat_quantres",
                                                                      width = 12,
                                                                      side = "right",
                                                                      tabPanel(title = "County Area in Farmland",
                                                                               fluidRow(
                                                                                 h4(strong("Percent of County Area in Farmland"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_nat_quantres_farmland")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_nat_quantres_farmland")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "County Area in Water",
                                                                               fluidRow(
                                                                                 h4(strong("Percent of County Area in Water"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_nat_quantres_water")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_nat_quantres_water")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Forestry Sales",
                                                                               fluidRow(
                                                                                 h4(strong("Forestry Sales per 10,000 Acres"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_nat_quantres_forestsales")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_nat_quantres_forestsales")
                                                                                 )
                                                                               )
                                                                      ),
                                                                      tabPanel(title = "Agri-Tourism and Recreational Revenue",
                                                                               fluidRow(
                                                                                 h4(strong("Agri-Tourism and Recreational Revenue per 10,000 Acres"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_nat_quantres_rev")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_nat_quantres_rev")
                                                                                 )
                                                                               )
                                                                      )
                                                               )
                                                             )
                                            ),
                                            #
                                            # QUALITY OF RESOURCES PANEL ------------------------------------------
                                            #
                                            
                                            conditionalPanel("input.natidx_choice == 'QUALITY OF RESOURCES'",
                                                             
                                                             fluidRow(
                                                               
                                                               box(title = "Quality of Resources Index",
                                                                   width = 12,
                                                                   h5(strong("County-Level Map")),
                                                                   leafletOutput("plot_nat_index_qualres")
                                                               )
                                                               
                                                             ),
                                                             fluidRow(
                                                               tabBox(title = "Quality of Resources Measures",
                                                                      id = "tab_indexnat_qualres",
                                                                      width = 12,
                                                                      side = "right",
                                                                      tabPanel(title = "Fine Particulate Matter",
                                                                               fluidRow(
                                                                                 h4(strong("Average Daily Density of Fine Particulate Matter"), align = "center"),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("County-Level Map")),
                                                                                   leafletOutput("plot_nat_qualres_part")
                                                                                 ),
                                                                                 column(
                                                                                   width = 6,
                                                                                   h5(strong("Indicator Box Plot")),
                                                                                   plotlyOutput("plotly_nat_qualres_part")
                                                                                 )
                                                                               )
                                                                      )
                                                               )
                                                             )
                                            )
                                    ),  
                                    
                                    # POLITICAL CAPITAL CONTENT -------------------------
                                    tabItem(tabName = "political",
                                            fluidRow(
                                              box(title = "About Political Capital",
                                                  width = 9,
                                                  "Political capital refers to the ability of a community to influence and enforce rules, regulations, 
                    and standards through their organizations, connections, voice, and power as citizens."
                                              ),
                                              box(title = "Select Your State",
                                                  width = 3,
                                                  selectInput("nat_whichstate", label = NULL,
                                                              choices = list("Iowa",
                                                                             "Oregon",
                                                                             "Virginia"), 
                                                              selected = "Iowa")
                                              )
                                            ),
                                            
                                            fluidRow(
                                              box(
                                                "COMING SOON."
                                              )
                                            )
                                    ),  
                                    
                                    # CULTURAL CAPITAL CONTENT -------------------------
                                    tabItem(tabName = "cultural",
                                            fluidRow(
                                              box(title = "About Cultural Capital",
                                                  width = 9,
                                                  "Cultural capital refers to the shared values, beliefs, dispositions, and perspectives that emanate 
                    from membership in a particular cultural group, often developing over generations, and provide a basis for 
                    collective efforts to solve community problems."
                                              ),
                                              box(title = "Select Your State",
                                                  width = 3,
                                                  selectInput("nat_whichstate", label = NULL,
                                                              choices = list("Iowa",
                                                                             "Oregon",
                                                                             "Virginia"), 
                                                              selected = "Iowa")
                                              )
                                            ),
                                            fluidRow(
                                              box(
                                                "COMING SOON."
                                              )
                                            )
                                    ),
                                    
                                    # DATA AND METHODS CONTENT -------------------------
                                    tabItem(tabName = "datamethods",
                                            fluidRow(
                                              box(width = 12,
                                                  title = "How We Measure Community Capitals",
                                                  "We create composite index measures to capture community capitals. Each composite index 
                                                  is based on multiple indicators as listed in the table below, selected on the basis of 
                                                  prior research and Extension community input. We compute quintile cut-offs for each 
                                                  indicator.  County placement in a higher quintile indicates a better relative position 
                                                  on the indicator compared to other counties; that is, it indicates an asset. To arrive
                                                  at the final index value, we average county quintile placement across the indicators 
                                                  composing the index. The more times a county places in the highest quintiles on relevant
                                                  indicators, the higher the index value, and the higher the community capital."),
                                              box(width = 12,
                                                  title = "Measures and Data Sources",
                                                  selectInput("topic", "Select capital:", width = "100%", choices = c(
                                                    "All",
                                                    "Financial",
                                                    "Human",
                                                    "Social",
                                                    "Natural", 
                                                    "Built", 
                                                    "Political", 
                                                    "Cultural")),
                                                  DTOutput("measures_table"))
                                            )
                                    ),
                                    
                                    # CONTACT CAPITAL CONTENT -------------------------
                                    tabItem(tabName = "contact",
                                            fluidRow(
                                              box(width = 4,
                                                  title = "About Us",
                                                  "We are a partnership of five universities—the University of Virginia, Virginia Tech, Virginia State University, 
                                                  Iowa State University, and Oregon State University—funded by the Bill & Melinda Gates Foundation to pilot 
                                                  an initiative that will use data science to unravel complex, community challenges and advance economic 
                                                  mobility across Virginia, Iowa, and Oregon.", 
                                                  br(""),
                                                    a(href = "https://datascienceforthepublicgood.org/economic-mobility/about", "Learn more about us.")
                                                  ),
                                              box(width = 4,
                                                  title = "Advancing Economic Mobility",
                                                  "This project is part of our Advancing Economic Mobility: Towards A National Community Learning Network initiative,
                                                  which will amplify the viability of Cooperate Extension professionals to discover opportunities and enable the 
                                                  integration of data-driven governance at local and state levels.", 
                                                  br(""),
                                                  a(href = "https://datascienceforthepublicgood.org/economic-mobility/", "Learn more about the initiative.")
                                              ),
                                              box(width = 4,
                                                  title = "Contact",
                                                  "Please direct inquiries to", a(href = "https://biocomplexity.virginia.edu/teja-pristavec", "Teja Pristavec."))
                                            )
                                    )      
                                  )
                    )
)


#
# SERVER ----------------------------------------------------------------------------------------------------
#

server <- function(input, output, session) {
  cbGreens <- c("#F7F7F7", "#D9F0D3", "#ACD39E", "#5AAE61", "#1B7837", "grey")
  
  # Function for indicator boxplots --------------------------
  create_boxplot <- function(data, myvar, myvarlabel) {
    
    group <- as.factor(data$state)
    
    data %>%
      plot_ly(colors = cbGreens2) %>%  
      add_trace(x = as.numeric(group),
                type = "box",
                fillcolor = "#BCBBBC",
                line = list(color = "#787878"),
                y = ~myvar,
                showlegend = F,
                hoverinfo = "y",
                marker = list(symbol = "asterisk-open", color = "#787878"),
                name = "") %>%
      add_markers(x = ~jitter(as.numeric(group), amount = 0.1), 
                  y = ~myvar, 
                  color = ~irr2010_discretize,
                  marker = list(size = 6, line = list(width = 1, color = "#3C3C3C")),
                  hoverinfo = "text",
                  text = ~paste0("Rurality Index: ", round(irr2010,2),
                                 "<br>County: ",county),
                  showlegend = TRUE) %>%
      layout(title = "",
             legend = list(title = list(text = "<b>Index of Relative\nRurality</b>")),
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
                na.label = "Not Available",
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
                opacity = 0.7,
                na.label = "Not Available")
  }
  
  # Switches
  fin_data <- reactive({datafin %>% filter(state == input$fin_whichstate)})
  hum_data <- reactive({datahum %>% filter(state == input$hum_whichstate)})
  soc_data <- reactive({datasoc %>% filter(state == input$soc_whichstate)})
  nat_data <- reactive({datanat %>% filter(state == input$nat_whichstate)})
  
  #
  # Capital Index Maps ------------------------------------------------
  #
  #
  # Financial-------------------------------------------------------
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
  # Human Index Maps ------------------------------------------------
  #
  
  output$plot_hum_index_health <- renderLeaflet({
    create_index(hum_data(), hum_data()$hum_index_health, "Health Index")
  })
  
  output$plot_hum_index_edu <- renderLeaflet({
    create_index(hum_data(), hum_data()$hum_index_edu, "Education Index")
  })
  
  output$plot_hum_index_childcare <- renderLeaflet({
    create_index(hum_data(), hum_data()$hum_index_child, "Child Care Index")
  })
  
  output$plot_hum_index_despair <- renderLeaflet({
    create_index(hum_data(), hum_data()$hum_index_despair, "Despair Index")
  })
  #
  # Social Index Maps--------------------------------------------------
  #
  output$plot_soc_index_socengage <- renderLeaflet({
    create_index(soc_data(), soc_data()$soc_index_eng, "Social Engagement Index")
  })
  output$plot_soc_index_relationships <- renderLeaflet({
    create_index(soc_data(), soc_data()$soc_index_relat, "Social Relationships Index")
  })
  output$plot_soc_index_isolation <- renderLeaflet({
    create_index(soc_data(), soc_data()$soc_index_isol, "Social Isolation Index")
  })
  
  #
  # Natural Index Maps--------------------------------------------------
  #
  output$plot_nat_index_quantres <- renderLeaflet({
    create_index(nat_data(), nat_data()$nat_index_quantres, "Quantity of Resources Index")
  })
  
  output$plot_nat_index_qualres <- renderLeaflet({
    create_index(nat_data(), nat_data()$nat_index_qualres, "Quantity of Resources Index")
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
  
  output$plotly_fin_ag_acres <- renderPlotly({
    
    data_var <- fin_data()$fin_pctagacres
    var_label <- "Percent of County in Agriculture Acres"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_ag_acres <- renderLeaflet({
    
    data_var <- fin_data()$fin_pctagacres
    var_label <- "Percent of County in Agriculture Acres"
    
    create_indicator(fin_data(), data_var, var_label)
  })
  
  
  output$plotly_fin_ag_landval <- renderPlotly({
    
    data_var <- fin_data()$fin_landvalacre
    var_label <- "Land Value Per Acre"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_ag_landval <- renderLeaflet({
    
    data_var <- fin_data()$fin_landvalacre
    var_label <- "Land Value Per Acre"
    
    create_indicator(fin_data(), data_var, var_label)
  })
  
  output$plotly_fin_ag_netin <- renderPlotly({
    
    data_var <- fin_data()$fin_netincperfarm
    var_label <- "Net Income Per Farm Operation"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_ag_netin <- renderLeaflet({
    
    data_var <- fin_data()$fin_netincperfarm
    var_label <- "Net Income Per Farm Operation"
    
    create_indicator(fin_data(), data_var, var_label)
  })
  
  output$plotly_fin_ag_employ <- renderPlotly({
    
    data_var <- fin_data()$fin_pctemplagri
    var_label <- "Percent Employed in Agriculture, Forestry, Fishing and Hunting, Mining Industry"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_ag_employ <- renderLeaflet({
    
    data_var <- fin_data()$fin_pctemplagri
    var_label <- "Percent Employed in Agriculture, Forestry, Fishing and Hunting, Mining Industry"
    
    create_indicator(fin_data(), data_var, var_label)
  })
  
  #
  # Financial - Economic Diversification Indicators - Boxplot and Map ------------------------------------
  #  
  
  
  output$plotly_fin_econdiv_emphhi <- renderPlotly({
    
    data_var <- fin_data()$fin_emphhi
    var_label <- "Herfindahl-Hirschman Index of Employment by Industry"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_econdiv_emphhi <- renderLeaflet({
    
    data_var <- fin_data()$fin_emphhi
    var_label <- "Herfindahl-Hirschman Index of Employment by Industry"
    
    create_indicator(fin_data(), data_var, var_label)
  })
  
  output$plotly_fin_econdiv_payhhi <- renderPlotly({
    
    data_var <- fin_data()$fin_aphhi
    var_label <- "Herfindahl-Hirschman Index of Payroll by Industry"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_econdiv_payhhi <- renderLeaflet({
    
    data_var <- fin_data()$fin_aphhi
    var_label <- "Herfindahl-Hirschman Index of Payroll by Industry"
    
    create_indicator(fin_data(), data_var, var_label)
  })
  
  #
  # Financial - Financial Well-Being Indicators - Boxplot and Map ------------------------------------
  #  
  
  output$plotly_fin_finwell_gini <- renderPlotly({
    
    data_var <- fin_data()$fin_gini
    var_label <- "Gini Index of Income Inequality"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_finwell_gini <- renderLeaflet({
    
    data_var <- fin_data()$fin_gini
    var_label <- "Gini Index of Income Inequality"
    
    create_indicator(fin_data(), data_var, var_label)
  })   
  
  output$plotly_fin_finwell_pov <- renderPlotly({
    
    data_var <- fin_data()$fin_pctinpov
    var_label <- "Percent with Income Below Poverty Level in Last 12 Months"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_finwell_pov <- renderLeaflet({
    
    data_var <- fin_data()$fin_pctinpov
    var_label <- "Percent with Income Below Poverty Level in Last 12 Months"
    
    create_indicator(fin_data(), data_var, var_label)
  })   
  
  output$plotly_fin_finwell_assist <- renderPlotly({
    
    data_var <- fin_data()$fin_pctassist
    var_label <- "Percent Households Receiving Public Assistance or SNAP"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_finwell_assist <- renderLeaflet({
    
    data_var <- fin_data()$fin_pctassist
    var_label <- "Percent Households Receiving Public Assistance or SNAP"
    
    create_indicator(fin_data(), data_var, var_label)
  })   
  
  output$plotly_fin_finwell_ssi <- renderPlotly({
    
    data_var <- fin_data()$fin_pctssi
    var_label <- "Percent Households Receiving Supplemental Security Income"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_finwell_ssi <- renderLeaflet({
    
    data_var <- fin_data()$fin_pctssi
    var_label <- "Percent Households Receiving Supplemental Security Income"
    
    create_indicator(fin_data(), data_var, var_label)
  })   
  
  output$plotly_fin_finwell_medinc <- renderPlotly({
    
    data_var <- fin_data()$fin_medinc
    var_label <- "Median Household Income"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_finwell_medinc <- renderLeaflet({
    
    data_var <- fin_data()$fin_medinc
    var_label <- "Median Household Income"
    
    create_indicator(fin_data(), data_var, var_label)
  })   
  
  output$plotly_fin_finwell_lessba <- renderPlotly({
    
    data_var <- fin_data()$fin_pctlessba
    var_label <- "Percent of People Older than 25 with Less than a Four Year Degree"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_finwell_lessba <- renderLeaflet({
    
    data_var <- fin_data()$fin_pctlessba
    var_label <- "Percent of People Older than 25 with Less than a Four Year Degree"
    
    create_indicator(fin_data(), data_var, var_label)
  }) 
  
  output$plotly_fin_finwell_debtcol <- renderPlotly({
    
    data_var <- fin_data()$fin_pctdebtcol
    var_label <- "Share of People with a Credit Bureau Record Who Have Any Debt in Collections"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_finwell_debtcol <- renderLeaflet({
    
    data_var <- fin_data()$fin_pctdebtcol
    var_label <- "Share of People with a Credit Bureau Record Who Have Any Debt in Collections"
    
    create_indicator(fin_data(), data_var, var_label)
  }) 
  
  #
  # Financial - Employment Indicators - Boxplot and Map ------------------------------------
  #  
  
  output$plotly_fin_employ_unempprecovid <- renderPlotly({
    
    data_var <- fin_data()$fin_unempprecovid
    var_label <- "Unemployment Rate Before COVID"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_employ_unempprecovid <- renderLeaflet({
    
    data_var <- fin_data()$fin_unempprecovid
    var_label <- "Unemployment Rate Before COVID"
    
    create_indicator(fin_data(), data_var, var_label)
  })  
  
  output$plotly_fin_employ_unempcovid <- renderPlotly({
    
    data_var <- fin_data()$fin_unempcovid
    var_label <- "Unemployment Rate During COVID"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_employ_unempcovid <- renderLeaflet({
    
    data_var <- fin_data()$fin_unempcovid
    var_label <- "Unemployment Rate During COVID"
    
    create_indicator(fin_data(), data_var, var_label)
  })  
  
  output$plotly_fin_employ_commute <- renderPlotly({
    
    data_var <- fin_data()$fin_pctcommute
    var_label <- "Percent Commuting 30min+"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_employ_commute <- renderLeaflet({
    
    data_var <- fin_data()$fin_pctcommute
    var_label <- "Percent Commuting 30min+"
    
    create_indicator(fin_data(), data_var, var_label)
  })  
  
  output$plotly_fin_employ_labforce <- renderPlotly({
    
    data_var <- fin_data()$fin_pctlabforce
    var_label <- "Percent of Working Age Population in Labor Force"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_employ_labforce <- renderLeaflet({
    
    data_var <- fin_data()$fin_pctlabforce
    var_label <- "Percent of Working Age Population in Labor Force"
    
    create_indicator(fin_data(), data_var, var_label)
  })  
  
  #
  # Human - Health Indicators - Boxplot and Map ------------------------------------
  #  
  
  output$plotly_hum_health_poorphys <- renderPlotly({
    
    data_var <- hum_data()$hum_numpoorphys
    var_label <- "Average Number of Reported Poor Physical Health Days in a Month"
    
    create_boxplot(hum_data(), data_var, var_label)
  })
  
  
  output$plot_hum_health_poorphys <- renderLeaflet({
    
    data_var <- hum_data()$hum_numpoorphys
    var_label <- "Average Number of Reported Poor Physical Health Days in a Month"
    
    create_indicator(hum_data(), data_var, var_label)
  })  
  
  output$plotly_hum_health_poorment <- renderPlotly({
    
    data_var <- hum_data()$hum_numpoormental
    var_label <- "Average Number of Reported Poor Physical Mental Days in a Month"
    
    create_boxplot(hum_data(), data_var, var_label)
  })
  
  
  output$plot_hum_health_poorment <- renderLeaflet({
    
    data_var <- hum_data()$hum_numpoormental
    var_label <- "Average Number of Reported Poor Physical Mental Days in a Month"
    
    create_indicator(hum_data(), data_var, var_label)
  })  
  
  output$plotly_hum_health_nophys <- renderPlotly({
    
    data_var <- hum_data()$hum_pctnophys
    var_label <- "Percentage of Adults that Report No Leisure-time Physical Activity"
    
    create_boxplot(hum_data(), data_var, var_label)
  })
  
  
  output$plot_hum_health_nophys <- renderLeaflet({
    
    data_var <- hum_data()$hum_pctnophys
    var_label <- "Percentage of Adults that Report No Leisure-time Physical Activity"
    
    create_indicator(hum_data(), data_var, var_label)
  })  
  
  output$plotly_hum_health_primcare <- renderPlotly({
    
    data_var <- hum_data()$hum_ratepcp
    var_label <- "Primary Care Physicians per 100,000 Population"
    
    create_boxplot(hum_data(), data_var, var_label)
  })
  
  
  output$plot_hum_health_primcare <- renderLeaflet({
    
    data_var <- hum_data()$hum_ratepcp
    var_label <- "Primary Care Physicians per 100,000 Population"
    
    create_indicator(hum_data(), data_var, var_label)
  })  
  
  output$plotly_hum_health_menthealthprov <- renderPlotly({
    
    data_var <- hum_data()$hum_ratementalhp
    var_label <- "Mental Health Providers per 100,000 Population"
    
    create_boxplot(hum_data(), data_var, var_label)
  })
  
  
  output$plot_hum_health_menthealthprov <- renderLeaflet({
    
    data_var <- hum_data()$hum_ratementalhp
    var_label <- "Mental Health Providers per 100,000 Population"
    
    create_indicator(hum_data(), data_var, var_label)
  })
  
  # 
  # Human - Education Indicators - Boxplot and Map ------------------------------------
  # 
  
  output$plotly_hum_edu_hs <- renderPlotly({
    
    data_var <- hum_data()$hum_pcths
    var_label <- "Percent of Population with At Least a High School Degree"
    
    create_boxplot(hum_data(), data_var, var_label)
  })
  
  
  output$plot_hum_edu_hs <- renderLeaflet({
    
    data_var <- hum_data()$hum_pcths
    var_label <- "Percent of Population with At Least a High School Degree"
    
    create_indicator(hum_data(), data_var, var_label)
  }) 
  
  output$plotly_hum_edu_read <- renderPlotly({
    
    data_var <- hum_data()$hum_reading
    var_label <- "Reading Proficiency"
    
    create_boxplot(hum_data(), data_var, var_label)
  })
  
  
  output$plot_hum_edu_read <- renderLeaflet({
    
    data_var <- hum_data()$hum_reading
    var_label <- "Reading Proficiency"
    
    create_indicator(hum_data(), data_var, var_label)
  }) 
  
  output$plotly_hum_edu_math <- renderPlotly({
    
    data_var <- hum_data()$hum_math
    var_label <- "Math Proficiency"
    
    create_boxplot(hum_data(), data_var, var_label)
  })
  
  
  output$plot_hum_edu_math <- renderLeaflet({
    
    data_var <- hum_data()$hum_math
    var_label <- "Math Proficiency"
    
    create_indicator(hum_data(), data_var, var_label)
  }) 
  # 
  # Human - Child Care Indicators - Boxplot and Map ------------------------------------
  #   
  output$plotly_hum_childcare_payratio <- renderPlotly({
    
    data_var <- hum_data()$hum_ratioFMpay
    var_label <- "Women to Men Pay Ratio"
    
    create_boxplot(hum_data(), data_var, var_label)
  })
  
  output$plot_hum_childcare_payratio <- renderLeaflet({
    
    data_var <- hum_data()$hum_ratioFMpay
    var_label <- "Women to Men Pay Ratio"
    
    create_indicator(hum_data(), data_var, var_label)
  })  
  
  output$plotly_hum_childcare_singpar <- renderPlotly({
    
    data_var <- hum_data()$hum_pctsngparent
    var_label <- "Percent of Children Living in a Single-Parent Household"
    
    create_boxplot(hum_data(), data_var, var_label)
  })
  
  output$plot_hum_childcare_singpar <- renderLeaflet({
    
    data_var <- hum_data()$hum_pctsngparent
    var_label <- "Percent of Children Living in a Single-Parent Household"
    
    create_indicator(hum_data(), data_var, var_label)
  })  
  
  output$plotly_hum_childcare_womenhs <- renderPlotly({
    
    data_var <- hum_data()$hum_pctFnohs
    var_label <- "Percent of Women Who did not Receive HS Diploma or Equivalent"
    
    create_boxplot(hum_data(), data_var, var_label)
  })
  
  output$plot_hum_childcare_womenhs <- renderLeaflet({
    
    data_var <- hum_data()$hum_pctFnohs
    var_label <- "Percent of Women Who did not Receive HS Diploma or Equivalent"
    
    create_indicator(hum_data(), data_var, var_label)
  })  
  
  #
  # Human - Despair Indicators - Boxplot and Map ------------------------------------
  #   
  output$plotly_hum_despair_divorce <- renderPlotly({
    
    data_var <- hum_data()$hum_pctdivorc
    var_label <- "Percent Divorced or Separated"
    
    create_boxplot(hum_data(), data_var, var_label)
  })
  
  output$plot_hum_despair_divorce <- renderLeaflet({
    
    data_var <- hum_data()$hum_pctdivorc
    var_label <- "Percent Divorced or Separated"
    
    create_indicator(hum_data(), data_var, var_label)
  }) 
  
  output$plotly_hum_despair_unemp <- renderPlotly({
    
    data_var <- hum_data()$hum_pctunemp
    var_label <- "Percent Population in Labor Force Unemployed"
    
    create_boxplot(hum_data(), data_var, var_label)
  })
  
  output$plot_hum_despair_unemp <- renderLeaflet({
    
    data_var <- hum_data()$hum_pctunemp
    var_label <- "Percent Population in Labor Force Unemployed"
    
    create_indicator(hum_data(), data_var, var_label)
  }) 
  
  output$plotly_hum_despair_whitemhs <- renderPlotly({
    
    data_var <- hum_data()$hum_whitemhs
    var_label <- "Percent White Men with High School Education or Lower"
    
    create_boxplot(hum_data(), data_var, var_label)
  })
  
  output$plot_hum_despair_whitemhs <- renderLeaflet({
    
    data_var <- hum_data()$hum_whitemhs
    var_label <- "Percent White Men with High School Education or Lower"
    
    create_indicator(hum_data(), data_var, var_label)
  }) 
  
  output$plotly_hum_despair_aggdeaths <- renderPlotly({
    
    data_var <- hum_data()$hum_ageratedeaths
    var_label <- "Age-adjusted Rate of Alcohol, Overdose, and Suicide Deaths Over 9 Years per 100,000 Population"
    
    create_boxplot(hum_data(), data_var, var_label)
  })
  
  output$plot_hum_despair_aggdeaths <- renderLeaflet({
    
    data_var <- hum_data()$hum_ageratedeaths
    var_label <- "Age-adjusted Rate of Alcohol, Overdose, and Suicide Deaths Over 9 Years per 100,000 Population"
    
    create_indicator(hum_data(), data_var, var_label)
  }) 
  #
  # Social - Engagement - Boxplot and Map ------------------
  # 
  output$plotly_soc_eng_census <- renderPlotly({
    
    data_var <- soc_data()$soc_overallcensusrate
    var_label <- "Census 2020 Mail and Online Self Response Rate"
    
    create_boxplot(soc_data(), data_var, var_label)
  })
  
  output$plot_soc_eng_census <- renderLeaflet({
    
    data_var <- soc_data()$soc_overallcensusrate
    var_label <- "Census 2020 Mail and Online Self Response Rate"
    
    create_indicator(soc_data(), data_var, var_label)
  })  
  
  output$plotly_soc_eng_turnout <- renderPlotly({
    
    data_var <- soc_data()$soc_voterrate
    var_label <- "Presidential Election 2016 Voter Turnout"
    
    create_boxplot(soc_data(), data_var, var_label)
  })
  
  output$plot_soc_eng_turnout <- renderLeaflet({
    
    data_var <- soc_data()$soc_voterrate
    var_label <- "Presidential Election 2016 Voter Turnout"
    
    create_indicator(soc_data(), data_var, var_label)
  }) 
  
  output$plotly_soc_eng_civic <- renderPlotly({
    
    data_var <- soc_data()$soc_assoctotal
    var_label <- "Number of Civic Associations and Establishments per 1,000 Population"
    
    create_boxplot(soc_data(), data_var, var_label)
  })
  
  output$plot_soc_eng_civic <- renderLeaflet({
    
    data_var <- soc_data()$soc_assoctotal
    var_label <- "Number of Civic Associations and Establishments per 1,000 Population"
    
    create_indicator(soc_data(), data_var, var_label)
  }) 
  
  output$plotly_soc_eng_nonprof <- renderPlotly({
    
    data_var <- soc_data()$soc_nonprofitpop
    var_label <- "Number of Non-Profit Organizations Including those with an International Approach"
    
    create_boxplot(soc_data(), data_var, var_label)
  })
  
  output$plot_soc_eng_nonprof <- renderLeaflet({
    
    data_var <- soc_data()$soc_nonprofitpop
    var_label <- "Number of Non-Profit Organizations Including those with an International Approach"
    
    create_indicator(soc_data(), data_var, var_label)
  })
  # 
  # Social - Relationships - Boxplot and Map ------------------
  #    
  output$plotly_soc_rel_juvarrests <- renderPlotly({
    
    data_var <- soc_data()$soc_juvarrest
    var_label <- "Number of Juvenile Arrests per 1000 Juveniles"
    
    create_boxplot(soc_data(), data_var, var_label)
  })
  
  output$plot_soc_rel_juvarrests <- renderLeaflet({
    
    data_var <- soc_data()$soc_juvarrest
    var_label <- "Number of Juvenile Arrests per 1000 Juveniles"
    
    create_indicator(soc_data(), data_var, var_label)
  }) 
  
  output$plotly_soc_rel_violentcrimes <- renderPlotly({
    
    data_var <- soc_data()$soc_violcrime
    var_label <- "Number of Violent Crimes per 100,000 Population"
    
    create_boxplot(soc_data(), data_var, var_label)
  })
  
  output$plot_soc_rel_violentcrimes <- renderLeaflet({
    
    data_var <- soc_data()$soc_violcrime
    var_label <- "Number of Violent Crimes per 100,000 Population"
    
    create_indicator(soc_data(), data_var, var_label)
  }) 
  
  output$plotly_soc_rel_grandparent <- renderPlotly({
    
    data_var <- soc_data()$soc_grandp
    var_label <- "Percent Grandparent Householders Responsible for Own Grandchildren"
    
    create_boxplot(soc_data(), data_var, var_label)
  })
  
  output$plot_soc_rel_grandparent <- renderLeaflet({
    
    data_var <- soc_data()$soc_grandp
    var_label <- "Percent Grandparent Householders Responsible for Own Grandchildren"
    
    create_indicator(soc_data(), data_var, var_label)
  }) 
  
  output$plotly_soc_rel_homeown <- renderPlotly({
    
    data_var <- soc_data()$soc_homeown
    var_label <- "Percent Homeowners"
    
    create_boxplot(soc_data(), data_var, var_label)
  })
  
  output$plot_soc_rel_homeown <- renderLeaflet({
    
    data_var <- soc_data()$soc_homeown
    var_label <- "Percent Homeowners"
    
    create_indicator(soc_data(), data_var, var_label)
  }) 
  
  output$plotly_soc_rel_samehouse <- renderPlotly({
    
    data_var <- soc_data()$soc_samehouse
    var_label <- "Percent Population Living in the Same House that They Lived in One Year Prior"
    
    create_boxplot(soc_data(), data_var, var_label)
  })
  
  output$plot_soc_rel_samehouse <- renderLeaflet({
    
    data_var <- soc_data()$soc_samehouse
    var_label <- "Percent Population Living in the Same House that They Lived in One Year Prior"
    
    create_indicator(soc_data(), data_var, var_label)
  }) 
  
  output$plotly_soc_rel_nonrel <- renderPlotly({
    
    data_var <- soc_data()$soc_nonrelat
    var_label <- "Percent Households with Nonrelatives Present"
    
    create_boxplot(soc_data(), data_var, var_label)
  })
  
  output$plot_soc_rel_nonrel <- renderLeaflet({
    
    data_var <- soc_data()$soc_nonrelat
    var_label <- "Percent Households with Nonrelatives Present"
    
    create_indicator(soc_data(), data_var, var_label)
  }) 
  # 
  # Social - Isolation - Boxplot and Map ------------------
  #       
  output$plotly_soc_iso_comp <- renderPlotly({
    
    data_var <- soc_data()$soc_computer
    var_label <- "Percent Households with a <br>Computing Device (Computer or Smartphone)"
    
    create_boxplot(soc_data(), data_var, var_label)
  })
  
  output$plot_soc_iso_comp <- renderLeaflet({
    
    data_var <- soc_data()$soc_computer
    var_label <- "Percent Households with a Computing Device (Computer or Smartphone)"
    
    create_indicator(soc_data(), data_var, var_label)
  }) 
  
  output$plotly_soc_iso_commute <- renderPlotly({
    
    data_var <- soc_data()$soc_commalone
    var_label <- "Percent Workers with More than <br>an Hour of Commute by Themselves"
    
    create_boxplot(soc_data(), data_var, var_label)
  })
  
  output$plot_soc_iso_commute <- renderLeaflet({
    
    data_var <- soc_data()$soc_commalone
    var_label <- "Percent Workers with More than an Hour of Commute by Themselves"
    
    create_indicator(soc_data(), data_var, var_label)
  }) 
  
  output$plotly_soc_iso_english <- renderPlotly({
    
    data_var <- soc_data()$soc_limiteng
    var_label <- "Percent of Residents that <br>are not Proficient in Speaking English"
    
    create_boxplot(soc_data(), data_var, var_label)
  })
  
  output$plot_soc_iso_english <- renderLeaflet({
    
    data_var <- soc_data()$soc_limiteng
    var_label <- "Percent of Residents that are not Proficient in Speaking English"
    
    create_indicator(soc_data(), data_var, var_label)
  }) 
  
  output$plotly_soc_iso_65alone <- renderPlotly({
    
    data_var <- soc_data()$soc_65alone
    var_label <- "Percent of All County Residents <br>Who are Both Over 65 and Live Alone"
    
    create_boxplot(soc_data(), data_var, var_label)
  })
  
  output$plot_soc_iso_65alone <- renderLeaflet({
    
    data_var <- soc_data()$soc_65alone
    var_label <- "Percent of All County Residents Who are Both Over 65 and Live Alone"
    
    create_indicator(soc_data(), data_var, var_label)
  }) 
  
  output$plotly_soc_iso_mentalhealth <- renderPlotly({
    
    data_var <- soc_data()$soc_freqmental
    var_label <- "Percent of People Who Indicated That They <br>Have More Than 14 Poor Mental Health <br>Days per Month (Frequent Mental Distress)"
    
    create_boxplot(soc_data(), data_var, var_label)
  })
  
  output$plot_soc_iso_mentalhealth <- renderLeaflet({
    
    data_var <- soc_data()$soc_freqmental
    var_label <- "Percent of People Who Indicated That They <br>Have More Than 14 Poor Mental Health <br>Days per Month (Frequent Mental Distress)"
    
    create_indicator(soc_data(), data_var, var_label)
  }) 
  
  output$plotly_soc_iso_suicide <- renderPlotly({
    
    data_var <- soc_data()$soc_suicrate
    var_label <- "Number of Suicides per 1,000 Population"
    
    create_boxplot(soc_data(), data_var, var_label)
  })
  
  output$plot_soc_iso_suicide <- renderLeaflet({
    
    data_var <- soc_data()$soc_suicrate
    var_label <- "Number of Suicides per 1,000 Population"
    
    create_indicator(soc_data(), data_var, var_label)
  }) 
  
  
  # 
  # 
  # Natural - Quantity of Resources - Boxplot and Map ------------------
  #    
  output$plotly_nat_quantres_farmland <- renderPlotly({
    
    data_var <- nat_data()$nat_pctagacres
    var_label <- "Percent of County Area in Farmland"
    
    create_boxplot(nat_data(), data_var, var_label)
  })
  
  output$plot_nat_quantres_farmland <- renderLeaflet({
    
    data_var <- nat_data()$nat_pctagacres
    var_label <- "Percent of County Area in Farmland"
    
    create_indicator(nat_data(), data_var, var_label)
  }) 
  
  output$plotly_nat_quantres_water <- renderPlotly({
    
    data_var <- nat_data()$nat_pctwater
    var_label <- "Percent of County Area in Water"
    
    create_boxplot(nat_data(), data_var, var_label)
  })
  
  output$plot_nat_quantres_water <- renderLeaflet({
    
    data_var <- nat_data()$nat_pctwater
    var_label <- "Percent of County Area in Water"
    
    create_indicator(nat_data(), data_var, var_label)
  }) 
  
  output$plotly_nat_quantres_forestsales <- renderPlotly({
    
    data_var <- nat_data()$nat_forestryrevper10kacres
    var_label <- "Forestry Sales per 10,000 Acres"
    
    create_boxplot(nat_data(), data_var, var_label)
  })
  
  #custom plot for forest sales
  
  output$plot_nat_quantres_forestsales <- renderLeaflet({
    
    custom <- nat_data()
    
    y <- ifelse(custom$nat_forestryrevper10kacres == 0, "0", 
                ifelse(is.na(custom$nat_forestryrevper10kacres) == T, NA, 
                       as.character(cut(custom$nat_forestryrevper10kacres, 
                                        breaks=c(quantile(custom[custom$nat_forestryrevper10kacres != 0, "nat_forestryrevper10kacres"] %>% st_drop_geometry(), 
                                                          probs = seq(0, 1, by = 0.25), na.rm = T)), dig.lab=10, include.lowest=TRUE))))
    z <- str_extract_all(string = y, pattern = "(\\[|\\()\\d+.\\.\\d{2}|\\d+.\\.\\d{2}|^0$", simplify = T)
    z <- as.data.frame(z)
    z$V3 <- ""
    
    for (i in 1:nrow(z)){
      if(!is.na(z[i, "V1"]) & !(z[i, "V1"] == "0")){
        z[i, "V3"] <-  paste(z[i, "V1"], ",", z[i, "V2"], "]", sep = "")
      } else if(!is.na(z[i, "V1"]) & z[i, "V1"] == "0"){
        z[i, "V3"] <- "0"
      } else{
        z[i, "V3"] = NA
      }
    }
    
    custom$cat <- factor(z$V3 , levels = c("0", "[35.45,955.56]", "(955.56,1587.77]", "(1587.77,5236.00]", "(5236.00,29449.17]"))
    
    pal <- colorFactor(cbGreens[1:5], custom$cat,
                       na.color = cbGreens[6])
    
    var_label <- "Forestry Sales per 10,000 Acres"
    
    labels <- lapply(
      paste("<strong>Area: </strong>",
            custom$NAME.y,
            "<br />",
            "<strong>", var_label, ": </strong>",
            round(custom$nat_agritourrevper10kacres, 2)),
      htmltools::HTML
    )
    
    leaflet(data = custom) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(fillColor = ~pal(cat),
                  fillOpacity = 0.7, 
                  stroke = TRUE, smoothFactor = 0.7, weight = 0.5, color = "#202020", label = labels,
                  labelOptions = labelOptions(direction = "bottom",
                                              style = list(
                                                "font-size" = "12px",
                                                "border-color" = "rgba(0,0,0,0.5)",
                                                direction = "auto"))) %>%
      addLegend("bottomleft",
                pal= pal,
                values =  ~(cat),
                title = "Value", 
                opacity = 0.7)
  }) 
  
  output$plotly_nat_quantres_rev <- renderPlotly({
    
    data_var <- nat_data()$nat_agritourrevper10kacres
    var_label <- "Agri-Tourism and Recreational Revenue per 10,000 Acres"
    
    create_boxplot(nat_data(), data_var, var_label)
  })
  
  # custom plot for agritourism
  output$plot_nat_quantres_rev <- renderLeaflet({
    
    custom <- nat_data()
    
    y <- ifelse(custom$nat_agritourrevper10kacres == 0, "0", 
                ifelse(is.na(custom$nat_agritourrevper10kacres) == T, NA, 
                       as.character(cut(custom$nat_agritourrevper10kacres, 
                                        breaks=c(quantile(custom[custom$nat_agritourrevper10kacres != 0, "nat_agritourrevper10kacres"] %>% st_drop_geometry(), 
                                                          probs = seq(0, 1, by = 0.25), na.rm = T)), dig.lab=10, include.lowest=TRUE))))
    
    z <- str_extract_all(string = y, pattern = "(\\[|\\()\\d+.\\.\\d{2}|\\d+.\\.\\d{2}|^0$", simplify = T)
    z <- as.data.frame(z)
    
    z$V3 <- ""
    
    for (i in 1:nrow(z)){
      if(!is.na(z[i, "V1"]) & !(z[i, "V1"] == "0")){
        z[i, "V3"] <-  paste(z[i, "V1"], ",", z[i, "V2"], "]", sep = "")
      } else if(!is.na(z[i, "V1"]) & z[i, "V1"] == "0"){
        z[i, "V3"] <- "0"
      } else{
        z[i, "V3"] = NA
      }
    }
    
    custom$cat <- factor(z$V3 , levels = c("0", "[26.58,371.27]", "(371.27,608.19]", "(608.19,1414.83]", "(1414.83,16509.72]"))
    
    pal <- colorFactor(cbGreens[1:5], custom$cat,
                       na.color = cbGreens[6])
    
    var_label <- "Agri-Tourism and Recreational Revenue per 10,000 Acres"
    
    labels <- lapply(
      paste("<strong>Area: </strong>",
            custom$NAME.y,
            "<br />",
            "<strong>", var_label, ": </strong>",
            round(custom$nat_agritourrevper10kacres, 2)),
      htmltools::HTML
    )
    
    leaflet(data = custom) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(fillColor = ~pal(cat),
                  fillOpacity = 0.7, 
                  stroke = TRUE, smoothFactor = 0.7, weight = 0.5, color = "#202020", label = labels,
                  labelOptions = labelOptions(direction = "bottom",
                                              style = list(
                                                "font-size" = "12px",
                                                "border-color" = "rgba(0,0,0,0.5)",
                                                direction = "auto"))) %>%
      addLegend("bottomleft",
                pal= pal,
                values =  ~(cat),
                title = "Value", 
                opacity = 0.7)
  }) 
  #
  # Natural - Quality of Resources - Boxplot and Map ------------------
  #      
  output$plotly_nat_qualres_part <- renderPlotly({
    
    data_var <- nat_data()$nat_particulatedensity
    var_label <- "Average Daily Density of Fine Particulate Matter"
    
    create_boxplot(nat_data(), data_var, var_label)
  })
  
  output$plot_nat_qualres_part <- renderLeaflet({
    
    data_var <- nat_data()$nat_particulatedensity
    var_label <- "Average Daily Density of Fine Particulate Matter"
    
    create_indicator(nat_data(), data_var, var_label)
  }) 
  
  
  #--------- Measures table -------------------------
  #
  measures_topic <- reactive({
    input$topic
  })
  
  output$measures_table <- renderDataTable({
    if(measures_topic() == "All"){
      table <- as.data.frame(measures)
      names(table) <- c("Capital", "Index", "Measure", "Data Source", "Year", "Geography")
      datatable(table, rownames = FALSE, options = list(pageLength = 15)) 
    }
    else{
      data <- switch(input$topic,
                     "Financial" = "financial",
                     "Human" = "human",
                     "Social" = "social",
                     "Natural" = "natural", 
                     "Built" = "built",
                     "Political" = "political", 
                     "Cultural" = "cultural")
      
      table <- measures[measures$capital == data, ]
      table <- as.data.frame(table)
      datatable(table, rownames = FALSE, options = list(pageLength = 15)) 
    }
  })
  
  
  
  
  # Home Page InfoBox outputs -------------------------------------------------
  # 
  
  output$fin_ibox <- renderInfoBox({
    infoBox(title = a("Financial Capital", onclick = "openTab('financial')", href="#"),
            color = "olive", icon = icon("money-check-alt"), 
            value = tags$h5("Financial capital refers to the economic features of the community such as debt capital, investment capital,
                            savings, tax revenue, tax abatements, and grants, as well as entrepreneurship, persistent poverty, 
                            industry concentration, and philanthropy.") 
    )
  })
  
  output$hum_ibox <- renderInfoBox({
    infoBox(title = a("Human Capital", onclick = "openTab('human')", href="#"),
            color = "olive", icon = icon("child"), 
            value = tags$h5("Human capital refers to the knowledge, skills, education, credentials, physical health, mental health, 
                            and other acquired or inherited traits essential for an optimal quality of life.")
    )
  })
  
  output$soc_ibox <- renderInfoBox({
    infoBox(title = a("Social Capital", onclick = "openTab('social')", href="#"),
            color = "olive", icon = icon("handshake"), 
            value = tags$h5("Social capital refers to the resources, information, and support that communities can access through 
                            the bonds among members of the community and their families promoting mutual trust, reciprocity, collective 
                            identity, and a sense of a shared future.")
    )
  })
  
  output$built_ibox <- renderInfoBox({
    infoBox(title = a("Built Capital", onclick = "openTab('built')", href="#"),
            color = "olive", icon = icon("home"), 
            value = tags$h5("Built capital refers to the physical infrastructure that facilitates community activities such as 
                            broadband and other information technologies, utilities, water/sewer systems, roads and bridges, 
                            business parks, hospitals, main street buildings, playgrounds, and housing stock.")
    )
  })
  
  output$nat_ibox <- renderInfoBox({
    infoBox(title = a("Natural Capital", onclick = "openTab('natural')", href="#"),
            color = "olive", icon = icon("tree"), 
            value = tags$h5("Natural capital refers to the stock of natural or environmental ecosystem assets that provides a flow 
                            of useful goods or services to create possibilities (and limits) to community development such as air, 
                            water, soil, biodiversity, and weather.")
    )
  })
  
  output$pol_ibox <- renderInfoBox({
    infoBox(title = a("Political Capital", onclick = "openTab('political')", href="#"),
            color = "olive", icon = icon("balance-scale-left"),
            value = tags$h5("Political capital refers to the ability of a community to influence and enforce rules, regulations, 
                            and standards through their organizations, connections, voice, and power as citizens.")
    )
  })
  
  output$cult_ibox <- renderInfoBox({
    infoBox(title = a("Cultural Capital", onclick = "openTab('cultural')", href="#"),
            color = "olive", icon = icon("landmark"), 
            value = tags$h5("Cultural capital refers to the shared values, beliefs, dispositions, and perspectives that emanate 
                            from membership in a particular cultural group, often developing over generations, and provide a basis 
                            for collective efforts to solve community problems.")
    )
  })
  
  
}


#
# APP ----------------------------------------------------------------------------------------------------
#

shinyApp(ui, server)