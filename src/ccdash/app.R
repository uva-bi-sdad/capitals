library(shinydashboard)
library(dashboardthemes)
library(shinydashboardPlus)
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
library(apputils)
library(shinyalert)
library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)

datafin <- read_rds("data/fin_final.Rds")
datahum <- read_rds("data/hum_final.Rds")
datasoc <- read_rds("data/soc_final.Rds")
datanat <- read_rds("data/nat_final.Rds")
datapol <- read_rds("data/pol_final_1.Rds")
datacult <- read_rds("data/cult_final.Rds")
databuilt <- read_rds("data/built_final.Rds")

measures <- read.csv("data/measures.csv")
biblio <- read.csv("data/bibliography.csv")

css_fix <- "div.info.legend.leaflet-control br {clear: both;}"
html_fix <- as.character(htmltools::tags$style(type = "text/css", css_fix))

legend_irr <- png::readPNG("www/legend_irr.png")


#
# USER INTERFACE ----------------------------------------------------------------------------------------------------
#

ui <- dashboardPage(title = "Economic Mobility Data Infrastructure",
                    
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
                      a(href = "https://datascienceforthepublicgood.org/economic-mobility", 
                        img(src = "logo.png", height = 60, width = 235)
                      ),
                      sidebarMenu(
                        hr(),
                        menuItem(text = "Community Capital Areas", tabName = "capitals", icon = icon("list-ol")),
                        menuItem(text = "Financial", tabName = "financial", icon = icon("money-check-alt")),
                        menuItem(text = "Human", tabName = "human", icon = icon("child")),
                        menuItem(text = "Social", tabName = "social", icon = icon("handshake")),
                        menuItem(text = "Natural", tabName = "natural", icon = icon("tree")),
                        menuItem(text = "Built", tabName = "built", icon = icon("home")),
                        menuItem(text = "Political", tabName = "political", icon = icon("landmark"),
                                 menuSubItem("Political Capital", tabName = "political"),
                                 menuSubItem("Policy Assets", tabName = "policyassets")), #icon("balance-scale-left")),
                        menuItem(text = "Cultural", tabName = "cultural", icon = icon("theater-masks")), 
                        hr(),
                        menuItem(text = "Data and Methods", tabName = "data", icon = icon("info-circle"),
                                 menuSubItem(text = "Measures Table", tabName = "datamethods"),
                                 menuSubItem(text = "Data Descriptions", tabName = "datadescription")),
                        menuItem(text = "Resources", tabName = "resources", icon = icon("book-open"),
                                 menuSubItem(text = "Bibliography", tabName = "biblio")),
                        menuItem(text = "About Us", tabName = "contact", icon = icon("address-card"))
                      )
                    ),
                    
                    dashboardBody(
                      HTML(html_fix),    
                      tags$style(
                        type = 'text/css', 
                        '.bg-olive {background-color: #FFFFFF!important; }'
                      ),
                      
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
                      useShinyalert(),
                      
                      # code to make video pop-up
                      tags$script('
                                  $( document ).ready(function() {
                                  var x = $("#vid").attr("src");
                                  $("#video_popup").on("hidden.bs.modal", function (event) {
                                  $("#vid").attr("src", "");
                                  });
                                  $("#video_popup").on("show.bs.modal", function(){
                                  $("#vid").attr("src", x);
                                  });
                                  })
                                  '),
                      
                      tabItems(
                        
                        # SUMMARY CONTENT -------------------------
                        
                        tabItem(tabName = "capitals",
                                fluidRow(
                                  box(width = 4,
                                      align = "left",
                                      title = "Economic Mobility Data Infrastructure",
                                      strong("Economic Mobility Data Infrastructure"), "builds on the community capitals framework by infusing the seven capital areas with a data science core.
                                      The resulting quantitative assessments are designed for characterizing economic mobility across multiple locales and promoting positive change.",
                                      br(""),
                                      "This dashboard is under construction and offers preliminary insights into community capitals in Iowa, Oregon, and Virginia.",
                                      br(""),
                                      "To view a", strong("tutorial"), "on how to use the dashboard, click ", actionLink("video_button", "here."),    #a(href = "https://youtu.be/uo25P_valhw", target = "_blank", "here."),
                                      
                                      # code to make video pop-up
                                      bsModal(id = "video_popup", title = "How to Use the Dashboard",
                                              trigger = "video_button", size = "large",
                                              HTML('<iframe id="vid" width="560" height="315" src="https://www.youtube-nocookie.com/embed/uo25P_valhw?rel=0" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>')),
                                      
                                      br(""),
                                      img(src = "framework.png", class = "topimage", width = "100%",
                                          style = "display: block; margin-left: auto; margin-right: auto; border: 0.5px solid #B4B4B4")
                                  ),
                                  
                                  box(width = 8,
                                      title = "Community Capital Areas",
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
                                  box(title = "Explore Composite Indices",
                                      width = 12,
                                      column(11,
                                             radioGroupButtons(
                                               inputId = "finidx_choice", 
                                               choices = c("COMMERCE", "AGRICULTURE", "ECONOMIC DIVERSIFICATION", 
                                                           "FINANCIAL WELL-BEING", "EMPLOYMENT"),
                                               checkIcon = list(yes = icon("angle-double-right")),
                                               direction = "horizontal", width = "100%",
                                               justified = FALSE, status = "success", individual = TRUE)
                                      ),
                                      column(1,
                                             circleButton(inputId = "infobutton_fin", icon = icon("info"), status = "info", size = "sm")
                                      )
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
                                                                       plotlyOutput("plotly_fin_co_bus")
                                                                     )
                                                                   )
                                                          ),
                                                          tabPanel(title = "Number of New Businesses",
                                                                   fluidRow(
                                                                     h4(strong("Number of New Businesses 2014-2018 per 10,000 People"), align = "center"),
                                                                     column(
                                                                       width = 6,
                                                                       h5(strong("County-Level Map")),
                                                                       leafletOutput("plot_fin_co_newbus")
                                                                     ),
                                                                     column(
                                                                       width = 6,
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                  box(title = "Explore Composite Indices",
                                      width = 12,
                                      column(11,
                                             radioGroupButtons(
                                               inputId = "humidx_choice", #label = "Make a choice :",
                                               choices = c("HEALTH", "EDUCATION", "CHILD CARE", 
                                                           "DESPAIR"),
                                               checkIcon = list(yes = icon("angle-double-right")),
                                               direction = "horizontal", width = "100%",
                                               justified = FALSE, status = "success", individual = TRUE),
                                             tags$script("$(\"input:radio[name='humidx_choice'][value='DESPAIR']\").parent().css('background-color', '#A59200');")
                                      ),
                                      column(1,
                                             circleButton(inputId = "infobutton_hum", icon = icon("info"), status = "info", size = "sm")
                                      )
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
                                                                       plotlyOutput("plotly_hum_edu_hs")
                                                                     )
                                                                   )
                                                          ),
                                                          tabPanel(title = "Reading Proficiency",
                                                                   fluidRow(
                                                                     h4(strong("Average Grade Level Performance for 3rd Graders on English Language Arts Standardized Tests"), align = "center"),
                                                                     column(
                                                                       width = 6,
                                                                       h5(strong("County-Level Map")),
                                                                       leafletOutput("plot_hum_edu_read")
                                                                     ),
                                                                     column(
                                                                       width = 6,
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
                                                                       plotlyOutput("plotly_hum_edu_read")
                                                                     )
                                                                   )
                                                          ),
                                                          tabPanel(title = "Math Proficiency",
                                                                   fluidRow(
                                                                     h4(strong("Average Grade Level Performance for 3rd Graders on Math Standardized Tests"), align = "center"),
                                                                     column(
                                                                       width = 6,
                                                                       h5(strong("County-Level Map")),
                                                                       leafletOutput("plot_hum_edu_math")
                                                                     ),
                                                                     column(
                                                                       width = 6,
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                       h5(strong("Measure Box Plot and Values by Rurality")),
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
                                    "Social capital refers to the resources, information, and support that communities can access through 
                                    the bonds among members of the community and their families  that promote mutual trust, reciprocity, 
                                    collective identity, and a sense of a shared future."
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
                                box(title = "Explore Composite Indices",
                                    width = 12,
                                    column(11,
                                           radioGroupButtons(
                                             inputId = "socidx_choice", #label = "Make a choice :",
                                             choices = c("SOCIAL ENGAGEMENT", "ISOLATION"), # SOCIAL RELATIONSHIPS
                                             checkIcon = list(yes = icon("angle-double-right")),
                                             justified = FALSE, status = "success", 
                                             direction = "horizontal", width = "100%", individual = TRUE),
                                           tags$script("$(\"input:radio[name='socidx_choice'][value='ISOLATION']\").parent().css('background-color', '#A59200');")
                                    ),
                                    column(1, 
                                           circleButton(inputId = "infobutton_soc", icon = icon("info"), status = "info", size = "sm"))
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
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_soc_eng_civic")
                                                                   )
                                                                 )
                                                        ),
                                                        tabPanel(title = "Non-Profit Organizations",
                                                                 fluidRow(
                                                                   h4(strong("Number of Non-Profit Organizations per 1,000 Population"), align = "center"),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_soc_eng_nonprof")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
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
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_soc_iso_suicide")
                                                                   )
                                                                 )
                                                        ),
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
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_soc_iso_comp")
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
                                    "Built capital refers to the physical infrastructure that facilitates community activities, such as 
                                    broadband and other information technologies, utilities, water/sewer systems, roads and bridges, business parks, 
                                    hospitals, main street buildings, playgrounds, and housing."
                                ),
                                box(title = "Select Your State",
                                    width = 3,
                                    selectInput("built_whichstate", label = NULL,
                                                choices = list("Iowa",
                                                               "Oregon",
                                                               "Virginia"), 
                                                selected = "Iowa")
                                )
                                ),
                              
                              fluidRow(
                                box(title = "Explore Composite Indices",
                                    width = 12,
                                    column(11,
                                           radioGroupButtons(
                                             inputId = "builtidx_choice", #label = "Make a choice :",       
                                             choices = c("HOUSING", "TELECOMMUNICATIONS", "TRANSPORTATION", "EDUCATION", "EMERGENCY", "CONVENTION"),   
                                             checkIcon = list(yes = icon("angle-double-right")),
                                             justified = FALSE, status = "success", 
                                             direction = "horizontal", width = "100%", individual = TRUE)
                                    ),
                                    #tags$script("$(\"input:radio[name='builtidx_choice'][value='HOUSING']\").parent().css('background-color', '#A59200');")),
                                    column(1,
                                           circleButton(inputId = "infobutton_built", icon = icon("info"), status = "info", size = "sm")
                                    )
                                )
                                
                              ),
                              
                              #
                              # HOUSING PANEL ------------------------------------------
                              #
                              
                              conditionalPanel("input.builtidx_choice == 'HOUSING'",
                                               
                                               fluidRow(
                                                 
                                                 box(title = "Housing Index",
                                                     width = 12,
                                                     h5(strong("County-Level Map")),
                                                     leafletOutput("plot_built_index_housing")
                                                 )
                                                 
                                               ),
                                               fluidRow(
                                                 tabBox(title = "Housing Measures",
                                                        id = "tab_indexbuilt_housing",
                                                        width = 12,
                                                        side = "right",
                                                        
                                                        tabPanel(title = "Single-Family Housing",
                                                                 fluidRow(
                                                                   h4(strong("Percentage of Households in Detached Single Family Units"), align = "center"),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_built_housing_singlefam")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_built_housing_singlefam")
                                                                   )
                                                                 )
                                                        ),
                                                        tabPanel(title = "Adequate Plumbing",
                                                                 fluidRow(
                                                                   h4(strong("Percentage of Households with Complete Plumbing"), align = "center"),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_built_housing_plumbing")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_built_housing_plumbing")
                                                                   )
                                                                 )
                                                        ),
                                                        tabPanel(title = "Non-Vacant Housing",
                                                                 fluidRow(
                                                                   h4(strong("Percentage of Non-Vacant Properties"), align = "center"),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_built_housing_nonvacant")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_built_housing_nonvacant")
                                                                   )
                                                                 )
                                                        ),
                                                        tabPanel(title = "Property Age",
                                                                 fluidRow(
                                                                   h4(strong("Median Year of Built Structures"), align = "center"),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_built_housing_medpropage")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_built_housing_medpropage")
                                                                   )
                                                                 )
                                                        ),
                                                        tabPanel(title = "Property Value",
                                                                 fluidRow(
                                                                   h4(strong("Median Household Property Value"), align = "center"),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_built_housing_medpropval")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_built_housing_medpropval")
                                                                   )
                                                                 )
                                                        )
                                                 )
                                               )
                              ),
                              
                              
                              
                              #
                              # TELECOMMUNICATIONS PANEL ------------------------------------------
                              #
                              
                              conditionalPanel("input.builtidx_choice == 'TELECOMMUNICATIONS'",
                                               
                                               fluidRow(
                                                 
                                                 box(title = "Telecommunications Index",
                                                     width = 12,
                                                     h5(strong("County-Level Map")),
                                                     leafletOutput("plot_built_index_telecom")
                                                 )
                                                 
                                               ),
                                               fluidRow(tabBox(title = "Telecommunications Measures",
                                                               id = "tab_indexbuilt_telecom",
                                                               width = 12,
                                                               side = "right",
                                                               
                                                               tabPanel(title = "Internet Use in Public Libraries",
                                                                        fluidRow(
                                                                          h4(strong("Uses of Public Internet Computers in Libaries per 100,000 Population"), align = "center"),
                                                                          column(
                                                                            width = 6,
                                                                            h5(strong("County-Level Map")),
                                                                            leafletOutput("plot_built_telecom_compuse")
                                                                          ),
                                                                          column(
                                                                            width = 6,
                                                                            h5(strong("Measure Box Plot and Values by Rurality")),
                                                                            plotlyOutput("plotly_built_telecom_compuse")
                                                                          )
                                                                        )
                                                               ),
                                                               tabPanel(title = "Public Computers",
                                                                        fluidRow(
                                                                          h4(strong("Number of Computers in Public Libraries per 100,000 Population"), align = "center"),
                                                                          column(
                                                                            width = 6,
                                                                            h5(strong("County-Level Map")),
                                                                            leafletOutput("plot_built_telecom_libcomps")
                                                                          ),
                                                                          column(
                                                                            width = 6,
                                                                            h5(strong("Measure Box Plot and Values by Rurality")),
                                                                            plotlyOutput("plotly_built_telecom_libcomps")
                                                                          )
                                                                        )
                                                               ),
                                                               tabPanel(title = "Public Libraries",
                                                                        fluidRow(
                                                                          h4(strong("Number of Public Libraries Per 100,000 Population"), align = "center"),
                                                                          column(
                                                                            width = 6,
                                                                            h5(strong("County-Level Map")),
                                                                            leafletOutput("plot_built_telecom_libs")
                                                                          ),
                                                                          column(
                                                                            width = 6,
                                                                            h5(strong("Measure Box Plot and Values by Rurality")),
                                                                            plotlyOutput("plotly_built_telecom_libs")
                                                                          )
                                                                        )
                                                               ),
                                                               tabPanel(title = "Cell Towers",
                                                                        fluidRow(
                                                                          h4(strong("Number of Cell Towers Per Acre"), align = "center"),
                                                                          column(
                                                                            width = 6,
                                                                            h5(strong("County-Level Map")),
                                                                            leafletOutput("plot_built_telecom_towers")
                                                                          ),
                                                                          column(
                                                                            width = 6,
                                                                            h5(strong("Measure Box Plot and Values by Rurality")),
                                                                            plotlyOutput("plotly_built_telecom_towers")
                                                                          )
                                                                        )
                                                               ),
                                                               tabPanel(title = "Broadband Availability",
                                                                        fluidRow(
                                                                          h4(strong("Percentage of Households with Broadband Subscription"), align = "center"),
                                                                          column(
                                                                            width = 6,
                                                                            h5(strong("County-Level Map")),
                                                                            leafletOutput("plot_built_telecom_hholdbband")
                                                                          ),
                                                                          column(
                                                                            width = 6,
                                                                            h5(strong("Measure Box Plot and Values by Rurality")),
                                                                            plotlyOutput("plotly_built_telecom_hholdbband")
                                                                          )
                                                                        )
                                                               ),
                                                               tabPanel(title = "Broadband Providers",
                                                                        fluidRow(
                                                                          h4(strong("Percentage of Households with at least Two Broadband Providers"), align = "center"),
                                                                          column(
                                                                            width = 6,
                                                                            h5(strong("County-Level Map")),
                                                                            leafletOutput("plot_built_telecom_2bbandpvdrs")
                                                                          ),
                                                                          column(
                                                                            width = 6,
                                                                            h5(strong("Measure Box Plot and Values by Rurality")),
                                                                            plotlyOutput("plotly_built_telecom_2bbandpvdrs")
                                                                          )
                                                                        )
                                                               )
                                               )
                                               )
                              ),
                              
                              #
                              # TRANSPORTATION PANEL ------------------------------------------
                              #
                              
                              conditionalPanel("input.builtidx_choice == 'TRANSPORTATION'",
                                               
                                               fluidRow(
                                                 
                                                 box(title = "Transportation Index",
                                                     width = 12,
                                                     h5(strong("County-Level Map")),
                                                     leafletOutput("plot_built_index_transpo")
                                                 )),
                                               
                                               fluidRow(
                                                 tabBox(title = "Transportation Measures",
                                                        id = "tab_indexhum_edu",
                                                        width = 12,
                                                        side = "right",
                                                        
                                                        tabPanel(title = "Miles of Roads",
                                                                 fluidRow(
                                                                   h4(strong("Miles of Roads per Acre"), align = "center"),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_built_miles")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_built_miles")
                                                                   )
                                                                 )
                                                        ),
                                                        tabPanel(title = "Total Roads",
                                                                 fluidRow(
                                                                   h4(strong("Total Roads per Acre"), align = "center"),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_built_roads")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_built_roads")
                                                                   )
                                                                 )
                                                        ),
                                                        tabPanel(title = "Bridge Quality",
                                                                 fluidRow(
                                                                   h4(strong("Percentage of Low Quality Bridges"), align = "center"),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_built_bridgequality")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_built_bridgequality")
                                                                   )
                                                                 )
                                                        ),
                                                        tabPanel(title = "Bridge Quantity",
                                                                 fluidRow(
                                                                   h4(strong("Number of Bridges per Acre"), align = "center"),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_built_bridges")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_built_bridges")
                                                                   )
                                                                 )
                                                        )
                                                 )
                                               )
                              ),
                              #
                              # EDUCATIONAL FACILITIES PANEL ------------------------------------------
                              #
                              
                              conditionalPanel("input.builtidx_choice == 'EDUCATION'",
                                               
                                               fluidRow(
                                                 
                                                 box(title = "Educational Facilities Index",
                                                     width = 12,
                                                     h5(strong("County-Level Map")),
                                                     leafletOutput("plot_built_index_edu")
                                                 )
                                                 
                                               ),
                                               fluidRow(tabBox(title = "Educational Facilities Measures",
                                                               id = "tab_indexbuilt_edu",
                                                               width = 12,
                                                               side = "right",
                                                               
                                                               tabPanel(title = "Supplementary Colleges",
                                                                        fluidRow(
                                                                          h4(strong("Number of Supplementary Colleges per 100,000 Population"), align = "center"),
                                                                          column(
                                                                            width = 6,
                                                                            h5(strong("County-Level Map")),
                                                                            leafletOutput("plot_built_suppcolleges")
                                                                          ),
                                                                          column(
                                                                            width = 6,
                                                                            h5(strong("Measure Box Plot and Values by Rurality")),
                                                                            plotlyOutput("plotly_built_suppcolleges")
                                                                          )
                                                                        )
                                                               ),
                                                               tabPanel(title = "Universities",
                                                                        fluidRow(
                                                                          h4(strong("Number of Universities per 100,000 Population"), align = "center"),
                                                                          column(
                                                                            width = 6,
                                                                            h5(strong("County-Level Map")),
                                                                            leafletOutput("plot_built_universities")
                                                                          ),
                                                                          column(
                                                                            width = 6,
                                                                            h5(strong("Measure Box Plot and Values by Rurality")),
                                                                            plotlyOutput("plotly_built_universities")
                                                                          )
                                                                        )
                                                               ),
                                                               tabPanel(title = "Private Schools",
                                                                        fluidRow(
                                                                          h4(strong("Number of Private Schools per 100,000 Population"), align = "center"),
                                                                          column(
                                                                            width = 6,
                                                                            h5(strong("County-Level Map")),
                                                                            leafletOutput("plot_built_private_schools")
                                                                          ),
                                                                          column(
                                                                            width = 6,
                                                                            h5(strong("Measure Box Plot and Values by Rurality")),
                                                                            plotlyOutput("plotly_built_private_schools")
                                                                          )
                                                                        )
                                                               ),
                                                               tabPanel(title = "Public Schools",
                                                                        fluidRow(
                                                                          h4(strong("Number of Public Schools per 100,000 Population"), align = "center"),
                                                                          column(
                                                                            width = 6,
                                                                            h5(strong("County-Level Map")),
                                                                            leafletOutput("plot_built_public_schools")
                                                                          ),
                                                                          column(
                                                                            width = 6,
                                                                            h5(strong("Measure Box Plot and Values by Rurality")),
                                                                            plotlyOutput("plotly_built_public_schools")
                                                                          )
                                                                        )
                                                               )
                                               )
                                               )
                              ),
                              
                              #
                              # EMERGENCY FACILITIES PANEL ------------------------------------------
                              #
                              
                              conditionalPanel("input.builtidx_choice == 'EMERGENCY'",
                                               
                                               fluidRow(
                                                 
                                                 box(title = "Emergency Facilities Index",
                                                     width = 12,
                                                     h5(strong("County-Level Map")),
                                                     leafletOutput("plot_built_index_emerg")
                                                 )
                                                 
                                               ),
                                               
                                               fluidRow(
                                                 tabBox(title = "Emergency Facilities Measures",
                                                        id = "tab_indexbuilt_emerg_facs",
                                                        width = 12,
                                                        side = "right",
                                                        
                                                        
                                                        #tabPanel(title = "All Emergency Facilities",
                                                        #         fluidRow(
                                                        #           h4(strong("All Emergency Facilities per 100,000 Population"), align = "center"),
                                                        #           column(
                                                        #             width = 6,
                                                        #             h5(strong("County-Level Map")),
                                                        #             leafletOutput("plot_built_emerg_facs")
                                                        #           ),
                                                        #           column(
                                                        #             width = 6,
                                                        #             h5(strong("Measure Box Plot and Values by Rurality")),
                                                        #             plotlyOutput("plotly_built_emerg_facs")
                                                        #           )
                                                        #         )
                                                        #),
                                                        tabPanel(title = "Police Stations",
                                                                 fluidRow(
                                                                   h4(strong("Police Stations per 100,000 Population"), align = "center"),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_built_police")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_built_police")
                                                                   )
                                                                 )
                                                        ),
                                                        tabPanel(title = "Fire Stations",
                                                                 fluidRow(
                                                                   h4(strong("Fire Stations per 100,000 Population"), align = "center"),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_built_fire")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_built_fire")
                                                                   )
                                                                 )
                                                        ),
                                                        tabPanel(title = "Mental Health",
                                                                 fluidRow(
                                                                   h4(strong("Mental Health Facilities per 100,000 Population"), align = "center"),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_built_mentalhealth")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_built_mentalhealth")
                                                                   )
                                                                 )
                                                        ),
                                                        tabPanel(title = "Urgent Care",
                                                                 fluidRow(
                                                                   h4(strong("Urgent Care Facilities per 100,000 Population"), align = "center"),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_built_urgentcare")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_built_urgentcare")
                                                                   )
                                                                 )
                                                        ),
                                                        tabPanel(title = "Hospitals",
                                                                 fluidRow(
                                                                   h4(strong("Hospitals per 100,000 Population"), align = "center"),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_built_hospitals")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_built_hospitals")
                                                                   )
                                                                 )
                                                        )
                                                 )
                                               )
                              ),
                              
                              
                              #
                              # CONVENTION FACILITIES PANEL ------------------------------------------
                              #
                              
                              conditionalPanel("input.builtidx_choice == 'CONVENTION'",
                                               
                                               fluidRow(
                                                 
                                                 box(title = "Convention Index",
                                                     width = 12,
                                                     h5(strong("County-Level Map")),
                                                     leafletOutput("plot_built_index_conv")
                                                 )
                                                 
                                               ),
                                               
                                               fluidRow(
                                                 tabBox(title = "Convention Facilities Measures",
                                                        id = "tab_indexbuilt_conv",
                                                        width = 12,
                                                        side = "right",
                 
                                                        tabPanel(title = "Sports Venues",
                                                                 fluidRow(
                                                                   h4(strong("Sports Venues per 100,000 Population"), align = "center"),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_built_sports")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_built_sports")
                                                                   )
                                                                 )
                                                        ),
                                                        tabPanel(title = "Fairgrounds/Convention Centers",
                                                                 fluidRow(
                                                                   h4(strong("Fairgrounds/Convention Centers per 100,000 Population"), align = "center"),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_built_fairgrounds")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_built_fairgrounds")
                                                                   )
                                                                 )
                                                        ),
                                                        tabPanel(title = "Places of Worship",
                                                                 fluidRow(
                                                                   h4(strong("Places of Worship per 100,000 Population"), align = "center"),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_built_worship")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_built_worship")
                                                                   )
                                                                 )
                                                        )
                                                 )
                                               )
                              )
                              
                              
                              
                              
                      ), 
                      
                      # NATURAL CAPITAL CONTENT -------------------------
                      tabItem(tabName = "natural",
                              
                              fluidRow(
                                box(title = "About Natural Capital",
                                    width = 9,
                                    "Natural capital refers to the stock of natural or environmental ecosystem assets that provide a flow of 
                                    useful goods or services to create possibilities and limits to community development, such as air, water, 
                                    soil, biodiversity, and weather."
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
                                box(title = "Explore Composite Indices",
                                    width = 12,
                                    column(11,
                                           radioGroupButtons(
                                             inputId = "natidx_choice", #label = "Make a choice :",
                                             choices = c("LAND RESOURCES", "WATER RESOURCES", "AIR RESOURCES", "DEPENDENCE", "VULNERABILITY"),
                                             checkIcon = list(yes = icon("angle-double-right")),
                                             justified = FALSE, status = "success", 
                                             direction = "horizontal", width = "100%", individual = TRUE)
                                    ),
                                    column(1,
                                           circleButton(inputId = "infobutton_nat", icon = icon("info"), status = "info", size = "sm")
                                    )
                                )
                                
                              ),
                              #
                              #  LAND RESOURCES ------------------------------------------
                              #
                              
                              conditionalPanel("input.natidx_choice == 'LAND RESOURCES'",
                                               
                                               fluidRow(
                                                 
                                                 box(title = "Land Resources Index ",
                                                     width = 12,
                                                     h5(strong("County-Level Map")),
                                                     leafletOutput("plot_nat_index_land")
                                                 )
                                                 
                                               ),
                                               fluidRow(
                                                 tabBox(title = "Land Resources Index Measures ",
                                                        id = "tab_indexnat_quantres",
                                                        width = 12,
                                                        side = "right",
                                                        tabPanel(title = "Farmland",
                                                                 fluidRow(
                                                                   #h4(strong("Percent of County Area in Farmland"), align = "center"),
                                                                   ##
                                                                   fluidRow(
                                                                     width = 12,
                                                                     column(11,
                                                                            h4(strong("Percent of County Area in Farmland"), align = "center")
                                                                     ),
                                                                     column(1
                                                                            # ,
                                                                            # #infobutton_fin
                                                                            # circleButton(inputId = "info_expl_farmland", icon = icon("info"), status = "info", size = "xs")
                                                                     )
                                                                   ),
                                                                   ##
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_nat_quantres_farmland")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_nat_quantres_farmland")
                                                                   )
                                                                 )
                                                        ),
                                                        #new forestland
                                                        tabPanel(title = "Forestland",
                                                                 fluidRow(
                                                                   #h4(strong("Percent of County Area in Forestland"), align = "center"),
                                                                   ##
                                                                   fluidRow(
                                                                     width = 12,
                                                                     column(11,
                                                                            h4(strong("Percent of County Area in Forestland"), align = "center")
                                                                     ),
                                                                     column(1
                                                                            # ,
                                                                            # #infobutton_fin
                                                                            # circleButton(inputId = "info_expl_forestland2", icon = icon("info"), status = "info", size = "xs")
                                                                     )
                                                                   ),
                                                                   ##
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_nat_quantres_forestland")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_nat_quantres_forestland")
                                                                   )
                                                                 )
                                                        ),
                                                        ##Timberland
                                                        tabPanel(title = "Timberland",
                                                                 fluidRow(
                                                                   #h4(strong("Percent of County Area in Timberland"), align = "center"),
                                                                   ##
                                                                   fluidRow(
                                                                     width = 12,
                                                                     column(11,
                                                                            h4(strong("Percent of County Area in Timberland"), align = "center")
                                                                     ),
                                                                     column(1
                                                                            # ,
                                                                            # #infobutton_fin
                                                                            # circleButton(inputId = "info_expl_timberland", icon = icon("info"), status = "info", size = "xs")
                                                                     )
                                                                   ),
                                                                   ##
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_nat_quantres_timberland")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_nat_quantres_timberland")
                                                                   )
                                                                 )
                                                        )
                                                        
                                                        
                                                 )
                                               )
                              ),
                              #
                              # WATER RESOURCES ------------------------------------------
                              #
                              
                              conditionalPanel("input.natidx_choice == 'WATER RESOURCES'",
                                               
                                               fluidRow(
                                                 
                                                 box(title = "Water Resources Index ",
                                                     width = 12,
                                                     h5(strong("County-Level Map")),
                                                     leafletOutput("plot_nat_index_water")
                                                 )
                                                 
                                               ),
                                               fluidRow(
                                                 tabBox(title = "Water Resources Index Measures",
                                                        id = "tab_indexnat_qualres",
                                                        width = 12,
                                                        side = "right",
                                                        tabPanel(title = "Water Area",
                                                                 fluidRow(
                                                                   #h4(strong("Percent of County Area in Water"), align = "center"),
                                                                   ##
                                                                   fluidRow(
                                                                     width = 12,
                                                                     column(11,
                                                                            h4(strong("Percent of County Area in Water"), align = "center")
                                                                     ),
                                                                     column(1
                                                                            # ,
                                                                            # #infobutton_fin
                                                                            # circleButton(inputId = "info_expl_countywater", icon = icon("info"), status = "info", size = "xs")
                                                                     )
                                                                   ),
                                                                   ##
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_nat_quantres_water")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_nat_quantres_water")
                                                                   )
                                                                 )
                                                        ),
                                                        #new total water withdrawals
                                                        tabPanel(title = "Water Withdrawals",
                                                                 fluidRow(
                                                                   #h4(strong("Total Water Withdrawals (Surface and Ground)"), align = "center"),
                                                                   ##
                                                                   fluidRow(
                                                                     width = 12,
                                                                     column(11,
                                                                            h4(strong("Total Water Withdrawals (Surface and Ground), Millions of Gallons per Day"), align = "center")
                                                                     ),
                                                                     column(1
                                                                            # ,
                                                                            # #infobutton_fin
                                                                            # circleButton(inputId = "info_expl_waterwithdrawal", icon = icon("info"), status = "info", size = "xs")
                                                                     )
                                                                   ),
                                                                   ##
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_nat_water_with")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_nat_water_with")
                                                                   )
                                                                 )
                                                        ),
                                                        #water with irrigation
                                                        tabPanel(title = "Irrigation",
                                                                 fluidRow(
                                                                   #h4(strong("Water Withdrawals for Irrigation"), align = "center"),
                                                                   ##
                                                                   fluidRow(
                                                                     width = 12,
                                                                     column(11,
                                                                            h4(strong("Water Withdrawals for Irrigation, Millions of Gallons per Day"), align = "center")
                                                                     ),
                                                                     column(1
                                                                            # ,
                                                                            # #infobutton_fin
                                                                            # circleButton(inputId = "info_expl_irrig", icon = icon("info"), status = "info", size = "xs")
                                                                     )
                                                                   ),
                                                                   ##
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_nat_irrig_water")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_nat_irrig_water")
                                                                   )
                                                                 )
                                                        ),
                                                        #water use
                                                        tabPanel(title = "Daily Use",
                                                                 fluidRow(
                                                                   #h4(strong("Water Wse - Domestic, Publicly Supplied (gallons/day)"), align = "center"),
                                                                   ##
                                                                   fluidRow(
                                                                     width = 12,
                                                                     column(11,
                                                                            h4(strong("Domestic Water Use, Publicly Supplied, Gallons per Day"), align = "center")
                                                                     ),
                                                                     column(1
                                                                            # ,
                                                                            # #infobutton_fin
                                                                            # circleButton(inputId = "info_expl_pcwateruse", icon = icon("info"), status = "info", size = "xs")
                                                                     )
                                                                   ),
                                                                   ##
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_nat_water_percapita_galday")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_nat_water_percapita_galday")
                                                                   )
                                                                 )
                                                        )
                                                        
                                                        
                                                        
                                                 )
                                               )
                              ), 
                              
                              # AIR RESOURCES  ------------------------------------------
                              conditionalPanel("input.natidx_choice == 'AIR RESOURCES'",
                                               
                                               fluidRow(
                                                 
                                                 box(title = "Air Resources Index ",
                                                     width = 12,
                                                     h5(strong("County-Level Map"))
                                                     ,
                                                     leafletOutput("plot_nat_index_air")
                                                 )
                                                 
                                               ),
                                               fluidRow(
                                                 tabBox(title = "Air Resources Index Measures ",
                                                        id = "tab_indexnat_qualres",
                                                        width = 12,
                                                        side = "right",
                                                        tabPanel(title = "Particulate Matter",
                                                                 fluidRow(
                                                                   #h4(strong("Average Daily Density of Fine Particulate Matter"), align = "center"),
                                                                   ##
                                                                   fluidRow(
                                                                     width = 12,
                                                                     column(11,
                                                                            h4(strong("Average Daily Density of Fine Particulate Matter"), align = "center")
                                                                     ),
                                                                     column(1
                                                                            # ,
                                                                            # #infobutton_fin
                                                                            # circleButton(inputId = "info_expl_partmatter", icon = icon("info"), status = "info", size = "xs")
                                                                     )
                                                                   ),
                                                                   ##
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_nat_qualres_part")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_nat_qualres_part")
                                                                   )
                                                                 )
                                                        ),
                                                        #new
                                                        tabPanel(title = "Pollution",
                                                                 fluidRow(
                                                                   #h4(strong("Annual Average Air Concentration Estimates In Microgram Per Cubic Meter"), align = "center"),
                                                                   ##
                                                                   fluidRow(
                                                                     width = 12,
                                                                     column(11,
                                                                            h4(strong("Annual Average Air Concentration Estimates In Microgram Per Cubic Meter"), align = "center")
                                                                     ),
                                                                     column(1
                                                                            # ,
                                                                            # #infobutton_fin
                                                                            # circleButton(inputId = "info_expl_airpollution", icon = icon("info"), status = "info", size = "xs")
                                                                     )
                                                                   ),
                                                                   ##
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_nat_airpollutionconc")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_nat_airconcenpollution")
                                                                   )
                                                                 )
                                                        ),
                                                        #new cancer risk
                                                        tabPanel(title = "Cancer Risk",
                                                                 fluidRow(
                                                                   #h4(strong("Annual Average Cancer Risk Estimates Per Million (Pollutant: Benzene)"), align = "center"),
                                                                   ##
                                                                   fluidRow(
                                                                     width = 12,
                                                                     column(11,
                                                                            h4(strong("Annual Average Cancer Risk Estimates Per Million (Pollutant: Benzene)"), align = "center")
                                                                     ),
                                                                     column(1
                                                                            # ,
                                                                            # #infobutton_fin
                                                                            # circleButton(inputId = "info_expl_cancerisk", icon = icon("info"), status = "info", size = "xs")
                                                                     )
                                                                   ),
                                                                   ##
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_nat_cancerisk")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_nat_cancerisk")
                                                                   )
                                                                 )
                                                        )
                                                        
                                                        
                                                 )
                                               )
                              ),
                              
                              ##GDP DEPENDENCE on NAT RESOURCES  ------------------------------------------
                              conditionalPanel("input.natidx_choice == 'DEPENDENCE'",
                                               
                                               fluidRow(
                                                 
                                                 box(title = "Natural Capital Dependence Index",
                                                     width = 12,
                                                     h5(strong("County-Level Map"))
                                                     ,
                                                     leafletOutput("plot_nat_index_produc")
                                                 )
                                                 
                                               ),
                                               fluidRow(
                                                 tabBox(title = "Natural Capital Dependence Index Measures, Percentage of GDP",
                                                        id = "tab_indexnat_qualres",
                                                        width = 12,
                                                        side = "right",
                                                        
                                                        tabPanel(title = "Agricultural Production",
                                                                 fluidRow(
                                                                   #h4(strong("County GDP - Agriculture, Forestry, Fishing and Hunting"), align = "center"),
                                                                   ##
                                                                   fluidRow(
                                                                     width = 12,
                                                                     column(11,
                                                                            h4(strong("County GDP - Agriculture, Forestry, Fishing and Hunting"), align = "center")
                                                                     ),
                                                                     column(1
                                                                            # ,
                                                                            # #infobutton_fin
                                                                            # circleButton(inputId = "info_expl_agproduction", icon = icon("info"), status = "info", size = "xs")
                                                                     )
                                                                   ),
                                                                   ##
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_nat_agric_gdp")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_nat_agric_gdp")
                                                                   )
                                                                 )
                                                        ),
                                                        
                                                        #mining gdp
                                                        tabPanel(title = "Mining Production",
                                                                 fluidRow(
                                                                   #h4(strong("County GDP -  Mining, quarrying, and oil and gas extraction"), align = "center"),
                                                                   ##
                                                                   fluidRow(
                                                                     width = 12,
                                                                     column(11,
                                                                            h4(strong("County GDP -  Mining, Quarrying, and Oil and Gas Extraction"), align = "center")
                                                                     ),
                                                                     column(1
                                                                            # ,
                                                                            # #infobutton_fin
                                                                            # circleButton(inputId = "info_expl_miningproduction", icon = icon("info"), status = "info", size = "xs")
                                                                     )
                                                                   ),
                                                                   ##
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_nat_mining_gdp")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_nat_mining_gdp")
                                                                   )
                                                                 )
                                                        )
                                                        
                                                        
                                                 )
                                               )
                              ),
                              
                              #VULNERABILITY TO CLIMATE  ------------------------------------------
                              conditionalPanel("input.natidx_choice == 'VULNERABILITY'",
                                               
                                               fluidRow(
                                                 
                                                 box(title = "Climate Vulnerability Index",
                                                     width = 12,
                                                     h5(strong("County-Level Map"))
                                                     ,
                                                     leafletOutput("plot_nat_index_vulner")
                                                 )
                                                 
                                               ),
                                               fluidRow(
                                                 tabBox(title = "Climate Vulnerability Index Measures ",
                                                        id = "tab_indexnat_qualres",
                                                        width = 12,
                                                        side = "right",
                                                        
                                                        tabPanel(title = "Flood Vulnerability",
                                                                 fluidRow(
                                                                   #h4(strong("Percent Area (Square Miles) Within FEMA Designated Flood Hazard Area"), align = "center"),
                                                                   ##
                                                                   fluidRow(
                                                                     width = 12,
                                                                     column(11,
                                                                            h4(strong("Percent Area (Square Miles) Within FEMA Designated Flood Hazard Area"), align = "center")
                                                                     ),
                                                                     column(1
                                                                            # ,
                                                                            # #infobutton_fin
                                                                            # circleButton(inputId = "info_expl_flood", icon = icon("info"), status = "info", size = "xs")
                                                                     )
                                                                   ),
                                                                   ##
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_nat_flood_haz_pcarea")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_nat_flood_haz_pcarea")
                                                                   )
                                                                 )
                                                        ),
                                                        #new vulnerability fire
                                                        tabPanel(title = "Fire Vulnerability",
                                                                 fluidRow(
                                                                   #h4(strong("Population Vulnerable To Predicted Surface Smoke From Wildland Fires"), align = "center"),
                                                                   ##
                                                                   fluidRow(
                                                                     width = 12,
                                                                     column(11,
                                                                            h4(strong("Population Vulnerable To Predicted Surface Smoke From Wildland Fires"), align = "center")
                                                                     ),
                                                                     column(1
                                                                            # ,
                                                                            # #infobutton_fin
                                                                            # circleButton(inputId = "info_expl_fire", icon = icon("info"), status = "info", size = "xs")
                                                                     )
                                                                   ),
                                                                   ##
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_nat_firevulnerab_pop")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_nat_firevulnerab_pop")
                                                                   )
                                                                 )
                                                        ),
                                                        #vulnerability heat curr
                                                        tabPanel(title = "Heat Vulnerability",
                                                                 fluidRow(
                                                                   #h4(strong("Number of Extreme Heat Days, 2016"), align = "center"),
                                                                   ##
                                                                   fluidRow(
                                                                     width = 12,
                                                                     column(11,
                                                                            h4(strong("Number of Extreme Heat Days (2016)"), align = "center")
                                                                     ),
                                                                     column(1
                                                                            # ,
                                                                            # #infobutton_fin
                                                                            # circleButton(inputId = "info_expl_heat", icon = icon("info"), status = "info", size = "xs")
                                                                     )
                                                                   ),
                                                                   ##
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_nat_ext_heatdays")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_nat_ext_heatdays")
                                                                   )
                                                                 )
                                                        ),
                                                        #vulnerability heat projected
                                                        tabPanel(title = "Projected Heat",
                                                                 fluidRow(
                                                                   #h4(strong("Number of Projected Extreme Heat Days (2022)"), align = "center"),
                                                                   ##
                                                                   fluidRow(
                                                                     width = 12,
                                                                     column(11,
                                                                            h4(strong("Number of Projected Extreme Heat Days (2020)"), align = "center")
                                                                     ),
                                                                     column(1
                                                                            # ,
                                                                            # #infobutton_fin
                                                                            # circleButton(inputId = "info_expl_heatproj", icon = icon("info"), status = "info", size = "xs")
                                                                     )
                                                                   ),
                                                                   ##
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("County-Level Map")),
                                                                     leafletOutput("plot_nat_ext_heatdays_proj")
                                                                   ),
                                                                   column(
                                                                     width = 6,
                                                                     h5(strong("Measure Box Plot and Values by Rurality")),
                                                                     plotlyOutput("plotly_nat_ext_heatdays_proj")
                                                                   )
                                                                 )
                                                        )
                                                        
                                                        
                                                        
                                                 )
                                               )
                              )
                              
                              
                              
                      ),
                      
                      # POLITICAL CAPITAL CONTENT -------------------------------------------------
                      
                      tabItem(tabName = "political",
                              
                              fluidRow(
                                box(title = "About Political Capital",
                                    width = 9,
                                    "Political capital refers to the ability of a community to influence and enforce rules, 
                                    regulations, and standards through their organizations, connections, voice, and power as citizens."
                                ),
                                box(title = "Select Your State",
                                    width = 3,
                                    selectInput("pol_whichstate", label = NULL,
                                                choices = list("Iowa",
                                                               "Oregon",
                                                               "Virginia"), 
                                                selected = "Iowa")
                                )
                                ),
                              
                              fluidRow(
                                box(
                                  width = 12,
                                  column(11,
                                         h4(strong("Explore Composite Indices"))
                                  ),
                                  column(1,
                                         #infobutton_fin
                                         circleButton(inputId = "pcindex_info", icon = icon("info"), status = "info", size = "sm")
                                  )
                                )
                                
                              ),
                              
                              # POLITICAL PANEL ------------------------------------------
                              
                              tabPanel("input.finidx_choice == 'POLITICAL CAPITAL INDEX'",
                                       
                                       fluidRow(
                                         
                                         box(title = "Political Capital Index",
                                             width = 12,
                                             leafletOutput("plot_political_index")
                                         )
                                         
                                       ),
                                       fluidRow(
                                         tabBox(title = "Political Capital Measures",
                                                id = "tab_indexfin_co",
                                                width = 12,
                                                side = "right",
                                                tabPanel(title = "Financial Contributions",
                                                         fluidRow(
                                                           h4(strong("Number of Individuals Contributing Financial Resources to Political Candidates per 1,000 People"), align = "center"),
                                                           column(
                                                             width = 6,
                                                             h5(strong("County-Level Map")),
                                                             leafletOutput("leaflet_contrib")
                                                           ),
                                                           column(
                                                             width = 6,
                                                             h5(strong("Measure Box Plot and Values by Rurality")),
                                                             plotlyOutput("plotly_contrib")
                                                           )
                                                         )
                                                ),
                                                tabPanel(title = "Participation",
                                                         fluidRow(
                                                           h4(strong("Number of Organizations per 1,000 People"), align = "center"),
                                                           column(
                                                             width = 6,
                                                             h5(strong("County-Level Map")),
                                                             leafletOutput("leaflet_organization")
                                                           ),
                                                           column(
                                                             width = 6,
                                                             h5(strong("Measure Box Plot and Values by Rurality")),
                                                             plotlyOutput("plotly_organization")
                                                           )
                                                         )
                                                )
                                                ,
                                                tabPanel(title = "Representation",
                                                         fluidRow(
                                                           h4(strong("Voter Turnout"), align = "center"),
                                                           column(
                                                             width = 6,
                                                             h5(strong("County-Level Map")),
                                                             leafletOutput("leaflet_voters")
                                                           ),
                                                           column(
                                                             width = 6,
                                                             h5(strong("Measure Box Plot and Values by Rurality")),
                                                             plotlyOutput("plotly_voters")
                                                           )
                                                         )
                                                )
                                                
                                         )
                                       )
                              )
                              
                    ),
                    
                    # POLICY ASSETS CONTENT -------------------------
                    tabItem(tabName = "policyassets",
                            fluidRow(style = "margin: 6px",
                                     width = 12, 
                                     fluidRow( width=12,
                                               br(),
                                               box(width = 12,
                                                   h4(strong("Domains of Policy Assets") ) ),
                                               
                                               column(title = "Policy Assets",
                                                      width = 6,
                                                      box(width = 12,
                                                          br(style="text-align: justify;", "Policy questions for each area were constructed to 
                                                             have a “Yes” or “No” response, where a “Yes” indicates the policy has the potential to have a positive impact based on empirical research. A response of “Yes” was assigned a value of 1. 
                                                             If the state did not have a particular policy or regulation, it was assigned a value of 0.
                                                             For example, Student Discipline is one of the sub-domains identified within the Education policy area. Multiple questions regarding Student Discipline were evaluated such as:"),
                                                          br(tags$li('Is there a ban on corporal punishment?'),
                                                             
                                                             tags$li('Are there in-school disciplinary approaches other than corporal punishment?')),
                                                          
                                                          br(style="text-align: justify;","According to Cuddy and Reeves (2014), students subject to corporal punishment performed worse than their peers in non-punitive environments. 
                                                             Therefore, if a state banned corporal punishment they received a value of 1, if corporal punishment was not banned or there was no policy or 
                                                             regulation on corporal punishment that policy question was assigned a 0."),
                                                          br(style="text-align: justify;","Policy areas have multiple domains. We standardized the scores by summing across a domain and dividing by the number of 
                                                             questions. The final score for a domain was calculated by taking the mean across the domains. The final score for a policy area was calculated 
                                                             by taking the mean across the domains. The following table summarizes the areas of policy and their respective domains. The specific questions and their values can be observed by choosing the respective area.") 
                                                          )
                                                          ),
                                               column(6, align= "center",
                                                      br(),
                                                      br(),
                                                      box(width = 12,
                                                          img(src = "policy_assets_img.png", height = 510 , width = 400)) 
                                               )
                                                          ),
                                     br(),
                                     br(),
                                     fluidRow(
                                       tabBox(title = "  ",
                                              id = "tab_indexfin_ag",
                                              width = 12,
                                              side = "left",
                                              tabPanel(title = "Education",
                                                       fluidRow(
                                                         column(4,
                                                                br(),
                                                                strong("Background"),
                                                                br(style="text-align: justify;","Education is a fundamental vehicle enabling economic mobility.   Timothy Bartik (Senior Economist at W.E. Upjohn Institute for Employment Research) states that for every one dollar invested in high quality early childhood programs, a state economy will benefit with a two to three dollar return on investment. "),
                                                                br(style="text-align: justify;","Four subdomains were identified: school climate, early childhood education, post-secondary affordability, and workforce development. There are 19 subcategories which are derived from 73 policy questions.  "),
                                                                br(style="text-align: justify;","a. As defined by the National School Climate Center", strong("School climate"), "refers to the quality and character of school life. School climate is based on patterns of students', parents' and school personnel's experience of school life and reflects norms, goals, values, interpersonal relationships, teaching and learning practices, and organizational structures. A sustainable, positive school climate fosters youth development and learning necessary for a productive, contributing and satisfying life in a democratic society.” It addresses suspensions, specific infractions and conditions; prevention and non-punitive behavioral interventions; monitoring and accountability; school resources for safety and truant/attendance officers; and state education agency support."),
                                                                br(style="text-align: justify;","b.", strong("Early childhood"), "includes those school years from pre-kindergarten to the third grade. Early childhood education policies group them by kindergarten requirements; teacher quality; school readiness and transitions; assessment intervention and retention; family engagement; and social-emotional learning."),
                                                                br(style="text-align: justify;","c.", strong("Post-secondary education"),"is the educational level following the completion of secondary education (high school). Post-secondary education includes non-degree credentials such as certifications, licenses, and work experience programs, as well as, college and professional degrees.  Post-secondary affordability policies grouped them by, need and merit based financial aid; financial aid; and free college."),
                                                                br(style="text-align: justify;","d.", strong("Workforce development."), "The Federal Workforce Innovation and Opportunity Act (WIOA) encourages state policymakers to seek ways to connect education, job seekers, and employers in their states by developing a one-stop delivery system that provides information on career and training services, access to employer programs and activities, and access to real-time labor market information. Workforce development policies grouped them by, statewide apprenticeships; connecting education to work; and post-secondary career and technical education.")
                                                         ),
                                                         
                                                         column(8, 
                                                                h3(strong( "Asset Map")),
                                                                br('The following figure summarizes the extent of every domain for each state.'),
                                                                plotOutput("political_dom_edu",  width = "auto", height=800)  
                                                         )
                                                       ),
                                                       hr(),
                                                       
                                                       tabPanel("Data Sources & References",
                                                                fluidRow(width =12,
                                                                         column(1),
                                                                         column(10, h3(strong("Data Sources and References")),
                                                                                br(),
                                                                                h3("Data Sources"),
                                                                                tags$a(href="https://www.ecs.org/research-reports/key-issues/postsecondary-affordability/", "Education Commission of The States: Postsecondary Affordability"),
                                                                                br(),
                                                                                tags$a(href="https://www.ecs.org/research-reports/key-issues/early-childhood-education/", "Education Commission of The States: Early Childhood Education"),
                                                                                br(),
                                                                                tags$a(href="https://www.ecs.org/research-reports/key-issues/workforce-development/", "Education Commission of The States: Workforce Development"),
                                                                                br(),
                                                                                tags$a(href="https://www.ecs.org/research-reports/key-issues/school-climate/", "Education Commission of The States: School Climate"),
                                                                                br(),
                                                                                tags$a(href="https://safesupportivelearning.ed.gov/sites/default/files/discipline-compendium/Oregon%20School%20Discipline%20Laws%20and%20Regulations.pdf/", "Oregon Compilation of School Discipline Laws and Regulations"),
                                                                                br(),
                                                                                tags$a(href="https://safesupportivelearning.ed.gov/sites/default/files/discipline-compendium/Virginia%20School%20Discipline%20Laws%20and%20Regulations.pdf", "Virginia Compilation of School Discipline Laws and Regulations"),
                                                                                br(),
                                                                                tags$a(href="https://safesupportivelearning.ed.gov/sites/default/files/discipline-compendium/Iowa%20School%20Discipline%20Laws%20and%20Regulations.pdf", "Iowa Compilation of School Discipline Laws and Regulations"),
                                                                                br(),
                                                                                
                                                                                h3("References"),
                                                                                tags$a(href="https://www.brookings.edu/research/hitting-kids-american-parenting-and-physical-punishment/", "Brookings Corporal Punishment"),
                                                                                br(),
                                                                                tags$a(href="https://www.pnas.org/content/116/17/8255", "PNAS Corporal Punishment"),
                                                                                br(),
                                                                                tags$a(href="https://www.ecs.org/50-state-comparison-postsecondary-education-funding/", "ECS Early Childhood Programs as Economic Development Tool"),
                                                                                br(),
                                                                                tags$a(href="https://cew.georgetown.edu/cew-reports/recovery-job-growth-and-education-requirements-through-2020/", "Georgetown Job Growth and Education Requirements through 2020"),
                                                                                br(),
                                                                                tags$a(href="https://www.luminafoundation.org/news-and-views/does-higher-education-really-increase-economic-mobility/", "Lumina Foundation: Does higher education really increase economic mobility?")
                                                                         )
                                                                ),
                                                                br(),
                                                                br()
                                                       )
                                              ), 
                                              
                                              tabPanel(title = "Employment",
                                                       fluidRow( 
                                                         column(4,
                                                                br(),
                                                                strong("Background"),
                                                                br(),
                                                                br(style="text-align: justify;","The majority of research on economic mobility focuses on income, particularly, labor income.  Policies regarding employment are essential to connect the ability to generate income of individuals with the probability to improve social and economic status.  Communities with adequate policies enhancing employment show significant improvements to overcome barriers that commonly maintain low levels of mobility.  Employment is the fastest and probably the most direct mechanism to access services of a strong and “healthy” middle class, such as, housing, childcare, high-performing schools, safe neighborhoods, college education, etc. Zimmerman (2008) suggests that there is evidence to support that increasing minimum wage legislation potentially benefits a considerable proportion of the population and legislation favoring unions increases mobility since union members typically earn higher wages than non-members (Card, 1996. Shea, 1997)."),
                                                                br(),
                                                                br(style="text-align: justify;","Three aspects serve as a theoretical umbrella to understand the impact of employment related policies on social mobility: wage legislation, organizing capacity and considerations for protections."),
                                                                br(style="text-align: justify;", strong("Wage"), "legislation seeks to highlight the existence of local policies regarding minimum wages.", strong("Organizing"), "refers to the presence of union-friendly orientation.  Finally,", strong("Protection"), " covers a wide range of details concerning different aspect of employment protection that go beyond monetary aspects and include paid sick leave, equal pay mandates, pregnancy benefits, family care, etc.  These categories are suggested by the Report on the Work index by Oxfam (Oxfam, 2018).  For instance, Oregon seems to have a high rank of work index since it has the fourth highest minimum wage, part of the top states allowing organization of workers in 2018, etc. On the other hand, Virginia seems to have one of the lowest minimum wages along with other 21 states, and Iowa occupies a middle position among all the states according to the Oxfam ranking.")
                                                         ),
                                                         column(8,
                                                                h3(strong( "Asset Map")),
                                                                br('The following figure summarizes the extent of every domain for each state.'),
                                                                plotOutput("political_dom_emp",  width = "auto", height = 800)
                                                         )
                                                       ),
                                                       hr(),
                                                       tabPanel("Data Sources & References",
                                                                fluidRow(width = 12,
                                                                         column(1),
                                                                         column(10, h3(strong("Data Sources and References")),
                                                                                br(),
                                                                                h3("Data Sources"),
                                                                                tags$a(href="https://policy-practice.oxfamamerica.org/work/poverty-in-the-us/best-states-to-work/",
                                                                                       "OXFAM: \"The Best and Worst States to work in America\""),
                                                                                br(),
                                                                                tags$a(href="https://statusofwomendata.org/state-data/",
                                                                                       "Status of Women: State Data"),
                                                                                br(),
                                                                                tags$a(href="https://www.osha.gov/stateplans ",
                                                                                       "OSHA: State Plans"),
                                                                                br(),
                                                                                
                                                                                h3("References"),
                                                                                tags$a(href="https://www.urban.org/sites/default/files/publication/31191/1001163-labor-market-institutions-and-economic-mobility.pdf", "Zimmerman, S.: \"Labor market institutions and economic mobility\""),
                                                                                br(),
                                                                                tags$a(href="https://davidcard.berkeley.edu/papers/union-struct-wage.pdf", "Card, David.: The Effect of Unions on the Structure of Wages: A Longitudinal Analysis."),
                                                                                br(),
                                                                                tags$a(href="https://s3.amazonaws.com/oxfam-us/www/static/media/files/Best_States_to_Work_Index.pdf", "OMFAM: \"The Best States To Work Index. A Guide To Labor Policy in US States\" "),
                                                                                br(),
                                                                                tags$a(href="http://papers.nber.org/papers/w6026 ", "Shea, John: \"Does Parents’ Money Matter?\" ")
                                                                                
                                                                         )
                                                                ),
                                                                br(),
                                                                br()
                                                       )
                                              ), 
                                              tabPanel(title = "Housing",
                                                       fluidRow(
                                                         column(4,  
                                                                br(),
                                                                strong("Background"),
                                                                br(style="text-align: justify;", "Housing policies are crucial to evidence how policies may affect economic mobility.  Low income families struggle to obtain low housing prices.  We researched various housing and zoning policies to better understand which legislation may promote or delay mobility."),
                                                                br(),
                                                                br(style="text-align: justify;","There are three main subdomains within housing and zoning policy: assistance policies, financial policies, and development policies."),
                                                                br(),
                                                                br(style="text-align: justify;",strong("Assistance"), "policies are programs and discounts which aid in reducing the cost of housing for disadvantaged individuals. Loan assistance programs for disabled members and first-time homeowners are examples."),
                                                                br(),
                                                                br(style="text-align: justify;","Housing", strong("Financial"), " policy describes policies which aid in covering costs to help provide a fair financial environment when purchasing or renting homes. This includes loan assistance programs, home price discounts and tax exemptions. By understanding housing financial policies and their effects on communities, we can understand which policies cultivate the ideal environment for economic mobility."),
                                                                br(),
                                                                br(style="text-align: justify;",strong("Development"), " policies are land use and planning regulations that influence the cost and equity of housing. Restricting the development of multi-unit housing, for example, can drive up the cost of housing.")
                                                         ), 
                                                         
                                                         column(8, 
                                                                h3(strong( "Asset Map")),
                                                                br('The following figure summarizes the extent of every domain for each state.'),
                                                                ###graph here
                                                                plotOutput("political_dom_hou",  width = "auto", height = 800)     
                                                         )
                                                       ),
                                                       hr(),
                                                       tabPanel("Data Sources & References",
                                                                fluidRow(width = 12,
                                                                         column(1),
                                                                         column(10, h3(strong("Data Sources and References")),
                                                                                br(),
                                                                                h3("Data Sources"),
                                                                                tags$a(href="https://www.fha.com/fha-grants?state=OR#:~:text=First%20Time%20Home%20Buyer%20Loan,within%20the%20City%20of%20Corvallis.", "Federal Housing Administration (FHA): \"States with First Time Home Buyer Programs\""),
                                                                                br(),
                                                                                tags$a(href="https://smartasset.com/mortgage/first-time-home-buyer-programs-iowa", "Smart Asset: \"First Time Home Buyer Programs in Iowa (2019)\""),
                                                                                br(),
                                                                                tags$a(href="https://m.vhda.com/loancombo.aspx", "Virginia Housing Development Authority (VHDA): \"Virginia Housing Loan Combo\""),
                                                                                br(),
                                                                                tags$a(href="https://www.legis.iowa.gov/docs/code/16.54.pdf", "Iowa Finance Authority (IFA): \"Home Ownership Assistance Programs in Iowa\""),
                                                                                br(),
                                                                                tags$a(href="https://www.vhda.com/Programs/Pages/MilitaryVeteransPrograms.aspx", "Virginia Housing Development Authority (VHDA): \"Virginia Housing and the US military\""),
                                                                                br(),
                                                                                tags$a(href= "https://www.iowafinance.com/homeownership/mortgage-programs/military-homeownership-assistance-program/#:~:text=We'd%20like%20to%20help,and%20Homes%20for%20Iowans%20programs", "Iowa Finance Authority (IFA): \"Military Homeownership Assistance Program\""),
                                                                                br(),
                                                                                tags$a(href="https://www.oregon.gov/odva/Benefits/Pages/Home-Loans.aspx#:~:text=ODVA%20Home%20Loan%20Program,than%20334%2C000%20veterans%20since%201945", "Oregon Department of Veterans' Affairs (ODVA): \"Benefits and Programs\""),
                                                                                br(),
                                                                                tags$a(href="https://www.militarytimes.com/home-hq/2018/08/21/not-just-va-7-more-states-with-veteran-friendly-home-loan-programs/", "Military Times: \"States with Veteran-Friendly Home Loan Programs\""),
                                                                                br(),
                                                                                tags$a(href="https://www.vhda.com/Programs/Pages/GrantingFreedom.aspx", "Virginia Housing Development Authority (VHDA): \"Granting Freedom Program\""),
                                                                                br(),
                                                                                tags$a(href="https://www.dvs.virginia.gov/benefits/real-estate-tax-exemption", "Virginia Department of Veterans' Services: \"Real Estate Tax Exemption\""),
                                                                                br(),
                                                                                tags$a(href="https://www.vhda.com/Programs/Pages/Programs.aspx", "Virginia Housing Development Authority (VHDA): \"Virginia Housing Programs\""),
                                                                                br(),
                                                                                tags$a(href="https://www.self.inc/blog/the-complete-guide-to-home-loans-for-people-with-disabilities", "Self: \"The Complete Guide to Home Loans for People with Disabilities\""),
                                                                                br(),
                                                                                tags$a(href="https://www.disabled-world.com/disability/finance/american-home-loans.php", "Disabled World: \"Disability Housing and Home Loans for Disabled Americans\""),
                                                                                br(),
                                                                                tags$a(href="https://tax.iowa.gov/sites/default/files/2019-08/PTCandRRPForecast.pdf ", "Iowa Department of Revenue: \"Iowa’s Disabled and Senior Citizens Property Tax Credit and Rent Reimbursement Program Expenditure Projections Study\""),
                                                                                br(),
                                                                                tags$a(href="https://www.eldercaredirectory.org/state-resources.htm", "Eldercare Directory: \"State Resources\""),
                                                                                br(),
                                                                                tags$a(href="https://www.hud.gov/states/virginia/homeownership/seniors", "The United States Department of Housing and Urban Development (HUD): \"Housing Resources for Seniors: Virginia\""),
                                                                                br(),
                                                                                tags$a(href="https://vda.virginia.gov/", "VDA: \"Office of Aging Services\""),
                                                                                br(),
                                                                                tags$a(href="https://www.seniorresource.com/virginia.htm", "Senior Resource: \"Virginia Senior Resources\""),
                                                                                br(),
                                                                                tags$a(href="https://www.hud.gov/states/virginia/renting", "The United States Department of Housing and Urban Development (HUD): \"Virginia Rental Help\""),
                                                                                br(),
                                                                                tags$a(href="https://www.portland.gov/phb/nplte#:~:text=In%201985%2C%20Oregon%20legislature%20authorized,held%20by%20charitable%2C%20nonprofit%20organizations.&text=program%20to%202027.-,The%20tax%20exemption%20is%20intended%20to%20benefit%20low%2Dincome%20renters,that%20provide%20this%20housing%20opportunity", "City of Portland, Oregon: \"Non-Profit Low Income Housing Limited Tax Exemption (NPLTE)\""),
                                                                                br(),
                                                                                tags$a(href="https://www.vhda.com/BusinessPartners/MFDevelopers/LIHTCProgram/Pages/LIHTCProgram.aspx", "Virginia Housing Development Authority (VHDA): \"Low-Income Housing Tax Credit Program\""),
                                                                                br(),
                                                                                tags$a(href="https://tax.iowa.gov/tax-credits-and-exemptions#:~:text=Iowa%20Low%2DRent%20Housing%20Exemption&text=Eligibility%3A%20Property%20owned%20and%20operated,no%20later%20than%20February%201", "Iowa Department of Revenue: \"Tax Credits and Exemptions\""),
                                                                                br(),
                                                                                tags$a(href="https://bpr.berkeley.edu/2018/06/01/how-portlands-right-to-return-is-indeed-right-to-return-housing-to-the-underrepresented/ ", "Berkeley Political Review: \"Portland's 'Right to Return'\""),
                                                                                
                                                                                h3("References"),
                                                                                tags$a(href="https://www.urban.org/sites/default/files/alfresco/publication-pdfs/2000428-Housing-Policy-Levers-to-Promote-Economic-Mobility.pdf", "Urban Institute: \"Housing Policy Levers to Promote Economic Mobility\""),
                                                                                br(),
                                                                                tags$a(href="https://www.cato.org/publications/policy-analysis/zoning-land-use-planning-housing-affordability", "The Cato Institute: \"Zoning, Land‐Use Planning, and Housing Affordability\""),
                                                                                br(),
                                                                                tags$a(href="https://www.dcpolicycenter.org/publications/economic-cost-land-use/", "DC Policy Center: \"The economic costs of land use regulations\""),
                                                                                br(),
                                                                                tags$a(href="https://www.urban.org/sites/default/files/publication/98758/lithc_how_it_works_and_who_it_serves_final_2.pdf", "Urban Institute: \"The Low-Income Housing Tax Credit\"")
                                                                                
                                                                         )
                                                                ),
                                                                br(),
                                                                br()
                                                       )
                                              ),
                                              
                                              tabPanel(title = "Law Enforcement",
                                                       fluidRow(
                                                         column(4, 
                                                                br(),
                                                                strong("Background"),
                                                                br(style="text-align: justify;", "Law enforcement policies play an essential role in economic
                                                                   mobility. Having a criminal record
                                                                   increases the difficulty to obtain a job. Moreover, the ramifications of a criminal record or an encounter with the law are 
                                                                   felt most by male citizens,
                                                                   particularly, Hispanic or Black men. Therefore, law enforcement becomes an increasingly important aspect of
                                                                   political capital that must be studied to understand economic mobility.  "),
                                                                
                                                                br(style="text-align: justify;", "Our research on law enforcement practices and policies identified of three main subdomains of interest: arrest and court proceedings, incarceration and community policing practices. The three subdomains are comprised of 20 policy questions which assess the existence or non-existence of a practice.  The entire dataset, both binary and qualitative, can be found by clicking on the “download CSV” button in the All Data tab in the Summary section of Data, Methods and Measures"),
                                                                br(style="text-align: justify;", "a.", strong("Arrest and Court Proceeding Policies"), " focused on the process of arresting and trying individuals in court. We analyzed stop and identify, bail, and civil asset forfeiture policies. Practices revealed inequalities across distinct socio-economic groups. For example, paying cash bail or having your assets seized has an effect on and is affected by an individual’s financial standing. In addition, we explored zero tolerance policies related to driving under the influence. "),
                                                                br(style="text-align: justify;", "b.", strong("Incarceration Practices"), " covers the policies that impact individuals held in state facilities. We focused on inmates’ rights as well as the equitability and social justness of practices within the facility and upon return to their communities.  Specifically, we assessed the ability to acquire skills and certifications, as well as, access necessary healthcare, youth adjudication and the death penalty. "),
                                                                br(style="text-align: justify;", "c.", strong("Community Policing Practices"), "explores the standards that officers must abide by in policing the community with a focus on the equality of standards. For example, custodial sexual misconduct policies are used to assess how states hold officers accountable for allegations of misconduct towards individuals under their custody. We include policies on body camera usage, demographic information collection and domestic violence related polices. Also, the nature of officer training programs, particularly those pertaining to treating individuals with mental health issues.")
                                                                ),
                                                         
                                                         column(8,
                                                                h3(strong( "Asset Map")),
                                                                br('The following figure summarizes the extent of every domain for each state.'),
                                                                ###graph here
                                                                plotOutput("political_dom_law",  width = "auto", height = 800)
                                                         )
                                                         ),
                                                       hr(),
                                                       tabPanel("Data Sources & References",
                                                                fluidRow(width = 12,
                                                                         column(1),
                                                                         column(10, h3(strong("Data Sources and References")),
                                                                                hr(), h3("Data Sources"),
                                                                                downloadButton("downloadData", "Download CSV"),
                                                                                
                                                                                br(),
                                                                                p("Key Data Sources are listed below. The entire list can be found by downloading the entire domain-specific dataset using the button above."),
                                                                                
                                                                                tags$a(href="https://justiceforwardva.com/bail-reform#:~:text=As%20it%20stands%2C%20Virginia%20employs,whether%20pretrial%20release%20is%20appropriate.&text=If%20a%20person%20cannot%20make,to%20pay%20the%20money%20bail.", "Justice Forward Virginia: Bail"),
                                                                                br(),
                                                                                tags$a(href="https://ij.org/activism/legislation/civil-forfeiture-legislative-highlights/", "Institute for Justice: Civil Forfeiture Reforms on the State Level"),
                                                                                br(),
                                                                                tags$a(href="https://www.aclu.org/state-standards-pregnancy-related-health-care-and-abortion-women-prison-0#hd4", "ACLU: State Standards For Pregnancy-related Health Care and Abortion for Women in Prison"),
                                                                                br(),
                                                                                tags$a(href="https://static.prisonpolicy.org/scans/sprcsmstatelaw.pdf", "PrisonPolicy.Org: Custodial Sexual Misconduct Laws: A State-by-State Legislative Review"),
                                                                                br(),
                                                                                tags$a(href="https://www.ncsl.org/research/civil-and-criminal-justice/state-trends-in-law-enforcement-legislation-2014-2017.aspx", "National Conference of State Legislature: State Trends in Law Enforcement"),
                                                                                br(),
                                                                                tags$a(href="https://statusofwomendata.org/explore-the-data/state-data/oregon/#violence-safety", "Status of Women in the United States"),
                                                                                br(),
                                                                                tags$a(href="https://www.sentencingproject.org/publications/private-prisons-united-states/#:~:text=In%20six%20states%20the%20private,%2C%20and%20Georgia%20(110%25).", "Sentencing Project: Private Prisons in the United States"),
                                                                                
                                                                                br(),
                                                                                tags$a(href="https://www.courts.oregon.gov/programs/inclusion/Documents/juvrights.pdf", "Courts.Oregon.Org: YOUTH FACES THE LAW:A Juvenile Rights Handbook"),
                                                                                br(),
                                                                                tags$a(href="https://deathpenaltyinfo.org/state-and-federal-info/state-by-state", "Death Penalty Information Center: State by State"),
                                                                                br(),
                                                                                
                                                                                h3("References"),
                                                                                tags$a(href="https://www.theatlantic.com/politics/archive/2015/12/how-families-pay-the-never-ending-price-of-a-criminal-record/433641/", "The Atlantic: How Families Pay the Never-Ending Price of a Criminal Record"),
                                                                                br(),
                                                                                tags$a(href="https://www.ncjrs.gov/pdffiles1/nij/grants/244756.pdf ", "NCJRS: Criminal Stigma, Race, Gender and Employment")
                                                                         )
                                                                ),
                                                                br(),
                                                                br()
                                                       )
                                                       ),
                                              
                                              tabPanel(title = "Taxation",
                                                       
                                                       fluidRow( 
                                                         column(4,
                                                                br(), 
                                                                strong("Background"),
                                                                br(style="text-align: justify;", "
                                                                   Taxation may influence economic mobility since it may change the patterns of wealth accumulation and the distribution of resources in society.
                                                                   Tax revenues are used to fund goods and services that drive mobility, under the principle of equality, such as education and health, and tax deduction and credit policies
                                                                   lower the cost of mobility enhancing goods. Taxation can also lead to the redistribution of wealth, an important part of combating wealth inequality."),
                                                                br(style="text-align: justify;", "Since 1979, income inequality in the United States has increased dramatically. In every state, the average income of the top 5% of households is at least 10 times
                                                                   that of the poorest 20%.  It is vital to understand how legislation of states may implement more progressive tax policies and re-evaluate regressive
                                                                   structures to boost economic mobility. Our research identified four main subdomains of tax policy: tax credits, wealth-related taxes, business tax policy, and the Gini index."),
                                                                br(style="text-align: justify;", strong("a. Tax credits"), "are negative marginal tax rates, or tax incentives, that reduce tax liability and increase tax refunds, which may improve economic mobility for low-income individuals.
                                                                   They ease low- to moderate-income family burdens by providing appropriate financial support for expenses like childcare, income tax, and property tax.  "),
                                                                br(style="text-align: justify;", strong("b: Taxes on inherited wealth"), "such as the estate and inheritance tax, largely affect the wealthiest individuals. These taxes help redistribute income and wealth and, thus improve economic mobility.
                                                                   Since wealth concentration has exacerbated in recent decades, wealth-related taxes help upend financial barriers for low-income people.  "),
                                                                br(style="text-align: justify;", strong("c: Businesses"), "create opportunities for employment, thus increasing incomes, and provide access to services that increase future earning potentials.
                                                                   States play a significant role in supporting businesses by nullifying corporate tax avoidance strategies to equalize the playing field between multimillion-dollar corporations and small businesses, as well as, creating a tax climate that fosters entrepreneurial efforts. "),
                                                                br(style="text-align: justify;", strong("d.  The Gini coefficient"), "is a measure of  dispersion intended to represent income or wealth inequality in a nation or area. Because the Gini coefficient measures inequality after the effects of taxes, by understanding how Gini indexes change as a result
                                                                   of tax policies and financial redistribution, we can better understand how tax policy can support economic mobility.  ")
                                                                ),
                                                         column(8,
                                                                h3(strong( "Asset Map")),
                                                                br('The following figure summarizes the extent of every domain for each state.'),
                                                                plotOutput("political_dom_tax",  width = "auto", height = 800))
                                                                ), 
                                                       hr(),
                                                       tabPanel("Data Sources & References",
                                                                fluidRow(width = 3,
                                                                         column(1),
                                                                         column(10, h3(strong("Data Sources and References")),
                                                                                br(),
                                                                                h3("Data Sources"),
                                                                                tags$a(href = "https://www.americanadoptions.com/blog/your-state-adoption-tax-credit-and-how-you-can-protect-it/", "American Adoptions"),
                                                                                br(),
                                                                                tags$a(href = "https://www.cbpp.org/27-states-plus-dc-require-combined-reporting-for-the-state-corporate-income-tax",
                                                                                       "CBPP: 27 states plus DC Require Combined Reporting for the State Corporate Income Tax"),
                                                                                br(),
                                                                                tags$a(href="https://www.irs.gov/credits-deductions/individuals/earned-income-tax-credit/states-and-local-governments-with-earned-income-tax-credit",
                                                                                       "IRS: States and Local Governments with Earned Income Tax Credit "),
                                                                                br(),
                                                                                tags$a(href = "https://itep.org/property-tax-circuit-breakers-2019/", "ITEP: Property Tax Circuit Breakers in 2019"),
                                                                                br(),
                                                                                tags$a(href = "https://www.livestories.com/statistics/iowa/des-moines-county-gini-index-income-inequality",
                                                                                       "Live Stories: Des Moines County Gini Index of Income Inequality"),
                                                                                br(),
                                                                                tags$a(href = "https://opportunityindex.cfnova.org/indicator/chart?region=&demographic=&indicator=12&date_start=2005&date_end=2017",
                                                                                       "Opportunity Index of Northern Virginia: Gini Coefficient"),
                                                                                br(),
                                                                                tags$a(href = "https://www.realized1031.com/capital-gains-tax-rate", "Realized: Capital Gain Tax Rates by State"),
                                                                                br(),
                                                                                tags$a(href = "https://files.taxfoundation.org/20180925174436/2019-State-Business-Tax-Climate-Index.pdf",
                                                                                       "Tax Foundation: State Business Tax Climate Index"),
                                                                                br(),
                                                                                tags$a(href = "https://taxfoundation.org/state-corporate-income-tax-rates-brackets-2020/",
                                                                                       "Tax Foundation: State Corporate Income Tax Rate Brackets 2020"),
                                                                                br(),
                                                                                tags$a(href="http://www.taxcreditsforworkersandfamilies.org/state-tax-credits/",
                                                                                       "TCFW: State Tax Credits"),
                                                                                br(),
                                                                                tags$a(href = "https://www.thebalance.com/state-estate-tax-and-exemption-chart-3505462", "The Balance: State Estate Tax and Exemption Chart"),
                                                                                br(),
                                                                                tags$a(href = "https://www.thebalance.com/state-inheritance-tax-chart-3505460", "The Balance: State Inheritance Tax Charts"),
                                                                                br(),
                                                                                tags$a(href = "https://www.qualityinfo.org/-/wage-inequality-in-oregon-a-wide-gap", "Quality Info: Wage Inequality in Oregon"),
                                                                                br(),
                                                                                tags$a(href = "https://en.wikipedia.org/wiki/List_of_U.S._states_by_Gini_coefficient",
                                                                                       "Wikipedia: List of U.S. States by Gini Coefficient"),
                                                                                br(),
                                                                                tags$a(href = "https://data.worldbank.org/indicator/SI.POV.GINI", "World Bank: Gini Index"),
                                                                                br(),
                                                                                
                                                                                h3("References"),
                                                                                tags$a(href="https://www.cbpp.org/research/state-budget-and-tax/how-state-tax-policies-can-stop-increasing-inequality-and-start",
                                                                                       "CBPP: How State Tax Policies Can Stop Increasing Inequality and Start Reducing it"),
                                                                                br(),
                                                                                tags$a(href = "https://www.cbpp.org/research/state-budget-and-tax/state-taxes-on-inherited-wealth",
                                                                                       "CBPP: State Taxes on Inherited Wealth"),
                                                                                br(),
                                                                                tags$a(href = "https://hbr.org/2015/01/3-ways-businesses-are-addressing-inequality-in-emerging-markets",
                                                                                       "Harvard Business Review: 3 Ways Businesses are Addressing Inequality in Emerging Markets"),
                                                                                br(),
                                                                                tags$a(href="https://www.fool.com/taxes/2020/02/15/your-2020-guide-to-tax-credits.aspx",
                                                                                       "Motley Fool: Your 2020 Guide to Tax Credits"),
                                                                                br()
                                                                                
                                                                         )
                                                                ) 
                                                       ), 
                                                       br(),
                                                       br()
                                                         ), 
                                              
                                              tabPanel(title = "Voting",
                                                       fluidRow( 
                                                         column(4,
                                                                br(),
                                                                strong("Background"),
                                                                br(style="text-align: justify;", "Chetty et al. (2014) established a positive correlation between social capital 
                                                                   and upward mobility. Social capital is a group level phenomena that reflects the cohesiveness of a community,
                                                                   the connections between people and organizations. Quantifying social capital relies on surrogate measurements 
                                                                   like the number of non-profits, response rate to the Census, voter turnout, the number of civic and social associations 
                                                                   (Rupasingha et al., 2006)."),
                                                                br(),
                                                                br(style="text-align: justify;", "Here we focus on policies that have potential to impact voter turnout such as 
                                                                   automatic voter registration, online registration, and voter photo ID requirements. Innovations in automatic voter 
                                                                   registration have streamlined the way Americans register to vote, by providing automatic registration at DMV offices 
                                                                   and social service agencies. These policies can dramatically increase the number of registered voters. For example, 
                                                                   since Oregon became the first state in the nation to implement automatic voter registration in 2016, registration rates 
                                                                   quadruple at DMV offices. In the first six months after automatic voter registration was implemented in Vermont on 
                                                                   January 1, 2017, registration rates jumped 62 percent when compared to the first half of 2016. In contrast, strict photo 
                                                                   ID policies block 11 percent of eligible voters that do not have government issued photo IDs and that percentage is even 
                                                                   higher among seniors, minorities, people with disabilities, low-income voters, and students.")
                                                                ),
                                                         column(8,
                                                                h3(strong( "Asset Map")),
                                                                br('The following figure summarizes the extent of every domain for each state.'),
                                                                ###graph here
                                                                plotOutput("political_dom_vot",  width = "auto", height = 800)
                                                         )
                                                                ),
                                                       hr(), 
                                                       
                                                       tabPanel("Data Sources & References",
                                                                fluidRow(width = 12,
                                                                         column(1),
                                                                         column(10, h3(strong("Data Sources and References")),
                                                                                br(),
                                                                                
                                                                                h3("Data Sources"),
                                                                                tags$a(href="https://www.ncsl.org/research/elections-and-campaigns/voter-id.aspx", "National Conference on State Legislatures: \" Voter Identification Requirements | Voter ID Laws\" "),
                                                                                br(),
                                                                                tags$a(href="https://www.ncsl.org/research/elections-and-campaigns/early-voting-in-state-elections.aspx", "National Conference on State Legislatures: \"State Laws Governing Early Voting \" "),
                                                                                br(),
                                                                                tags$a(href="https://evic.reed.edu/", "EVIC: Early Voting Information Center"),
                                                                                br(),
                                                                                tags$a(href="https://www.vote.org/early-voting-calendar/", "Vote.org: \"Early Voting by State \" "),
                                                                                br(),
                                                                                tags$a(href="https://www.elections.virginia.gov/casting-a-ballot/absentee-voting/index.html", "Virgnia Department of Elections: \" Absentee and Early Voting\""),
                                                                                br(),
                                                                                tags$a(href="https://ballotpedia.org/Absentee/mail-in_voting", "Ballotopedia: Absentee/mail-in voting"),
                                                                                br(),
                                                                                tags$a(href="https://www.ncsl.org/research/elections-and-campaigns/absentee-and-early-voting.aspx", "National Conference on State Legislatures: \" Voting Outside the Polling Place- Absentee, All-Mail and other Voting at Home Options \" "),
                                                                                br(),
                                                                                tags$a(href="https://www.ncsl.org/research/elections-and-campaigns/felon-voting-rights.aspx", "National Conference on State Legislatures: \"Felon Voting Rights \""),
                                                                                br(),
                                                                                tags$a(href="https://www.ncsl.org/research/elections-and-campaigns/voter-registration.aspx", "National Conference on State Legislatures: \"Voter Registration \""),
                                                                                br(),
                                                                                tags$a(href="https://www.ncsl.org/research/elections-and-campaigns/automatic-voter-registration.aspx", "National Conference on State Legislatures: \"Automatic Voter Registration \""),
                                                                                br(),
                                                                                tags$a(href="https://www.brennancenter.org/our-work/research-reports/history-avr-implementation-dates", "Brennan Center for Justice: \"History of AVR & Implementation Dates \" "),
                                                                                br(),
                                                                                tags$a(href="https://www.fhwa.dot.gov/policyinformation/quickfinddata/qfdrivers.cfm", "Office of Highway Policy Information: \"Drivers and Driver Licensing\" "),
                                                                                br(),
                                                                                tags$a(href="https://www.ncsl.org/research/elections-and-campaigns/electronic-or-online-voter-registration.aspx", "National Conference on State Legislatures: \"Online Voter Registration \""),
                                                                                br(),
                                                                                tags$a(href="https://www.ncsl.org/research/elections-and-campaigns/voter-registration-deadlines.aspx", "National Conference on State Legislatures: \"Voter Registration Deadlines \""),
                                                                                br(),
                                                                                tags$a(href="https://www.vote.org/voter-registration-deadlines/", "Vote.org: \"Voter Registration Deadlines\" "),
                                                                                br(),
                                                                                tags$a(href="-https://www.ncsl.org/research/elections-and-campaigns/preregistration-for-young-voters.aspx", "National Conference on State Legislatures: \"Preregistration for Young \" "),
                                                                                br(),
                                                                                tags$a(href="https://www.elections.virginia.gov/registration/how-to-register/", "Virgnia Department of Elections: \"How to Register\" "),
                                                                                br(),
                                                                                
                                                                                h3("References"),
                                                                                tags$a(href="https://www.brennancenter.org/our-work/research-reports/automatic-voter-registration-summary", "Brennan Center for Justice: Automatic Voter Registration a Summary"),
                                                                                br(),
                                                                                tags$a(href="https://www.brennancenter.org/issues/ensure-every-american-can-vote/vote-suppression/voter-id", "Brennan Center for Justice: Voter ID"),
                                                                                br(),
                                                                                tags$a(href="https://www.nber.org/papers/w19843 ", "Chetty, R., Hendren, N., Kline, P., & Saez, E.: Where is the Land of Opportunity? The Geography of Intergenerational Mobility in the United States."),
                                                                                br(),
                                                                                tags$a(href="https://www.researchgate.net/publication/222822589_The_Production_of_Social_Capital_in_US_Counties", "Rupasingha, A., Goetz, S. J., & Freshwater, D.: The production of social capital in US counties. Journal of Socio-Economics")
                                                                                
                                                                         ) 
                                                                ),
                                                                br(),
                                                                br()
                                                       )
                                                         )
                                              
                                                       )
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
                                  selectInput("cult_whichstate", label = NULL,
                                              choices = list("Iowa",
                                                             "Oregon",
                                                             "Virginia"), 
                                              selected = "Iowa")
                              )
                              ),
                            fluidRow(
                              box(title = "Explore Diversity Measures",
                                  width = 12,
                                  column(11,
                                         radioGroupButtons(
                                           inputId = "cultidx_choice", 
                                           choices = c("RELIGION", "ANCESTRY"),
                                           checkIcon = list(yes = icon("angle-double-right")),
                                           direction = "horizontal", width = "100%",
                                           justified = FALSE, status = "success", individual = TRUE)
                                  ),
                                  column(1,
                                         circleButton(inputId = "infobutton_cult", icon = icon("info"), status = "info", size = "sm")
                                  )
                              )
                              
                            ),
                            
                            conditionalPanel("input.cultidx_choice == 'RELIGION'",
                                             
                                             fluidRow(
                                               
                                               box(title = "Number of Religious Groups",
                                                   width = 6,
                                                   h5(strong("County-Level Map")),
                                                   leafletOutput("plot_cult_index_rich"), 
                                                   h5(strong("Measure Box Plot and Values by Rurality")),
                                                   plotlyOutput("plotly_cult_index_rich")
                                               ),
                                               
                                               box(title = "Gini-Simpson Diversity Index",
                                                   width = 6,
                                                   h5(strong("County-Level Map")),
                                                   leafletOutput("plot_cult_index_gsi"),
                                                   h5(strong("Measure Box Plot and Values by Rurality")),
                                                   plotlyOutput("plotly_cult_index_gsi")
                                               )
                                               
                                               
                                             )
                            ),
                            
                            conditionalPanel("input.cultidx_choice == 'ANCESTRY'",
                                             
                                             fluidRow(
                                               
                                               box(title = "Number of Ancestry Groups",
                                                   width = 6,
                                                   h5(strong("County-Level Map")),
                                                   leafletOutput("plot_cult_index_ancrich"), 
                                                   h5(strong("Measure Box Plot and Values by Rurality")),
                                                   plotlyOutput("plotly_cult_index_ancrich")
                                               ),
                                               
                                               box(title = "Gini-Simpson Diversity Index",
                                                   width = 6,
                                                   h5(strong("County-Level Map")),
                                                   leafletOutput("plot_cult_index_ancgsi"),
                                                   h5(strong("Measure Box Plot and Values by Rurality")),
                                                   plotlyOutput("plotly_cult_index_ancgsi")
                                               )
                                               
                                               
                                             )
                            )
                            
                            
                    ),
                    
                    # DATA AND METHODS CONTENT -------------------------
                    tabItem(tabName = "datamethods",
                            fluidRow(
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
                    # DATA DESCRIPTION CONTENT -------------------------
                    tabItem(tabName = "datadescription",
                            fluidRow(
                              box(width = 12,
                                  title = "Data Descriptions",
                                  column(4,
                                         flipBox(
                                           id = 1,
                                           box_width = 8,
                                           main_img = "dataseticons/acs.jpg",
                                           front_title = "American Community Survey",
                                           back_title = "About the Data",
                                           back_content = tagList(
                                             tags$div("The", tags$a("American Community Survey (ACS)", href= "https://www.census.gov/programs-surveys/acs"),
                                                      "is an ongoing yearly survey conducted by the U.S Census Bureau. 
                                                      ACS samples households to compile 1-year and 5-year datasets providing 
                                                      information on population sociodemographic and socioeconomic characteristics.
                                                      ACS is available at census block group geographic level and above.")
                                             )
                                             ),
                                         br(""),
                                         flipBox(
                                           id = 3,
                                           box_width = 8,
                                           main_img = "dataseticons/bls.jpg",
                                           front_title = "Local Area Unemployment Statistics",
                                           back_title = "About the Data",
                                           back_content = tagList(
                                             tags$div("The", tags$a("Local Area Unemployment Statistics dataset", href = "https://www.bls.gov/lau/"), "is published by the Bureau of Labor 
                                                      Statistics (BLS), which is charged with collecting data on the labor force. The dataset
                                                      includes annual information about unemployment. BLS provides data at the county level and above.")
                                             )
                                             ),
                                         br(),
                                         flipBox(
                                           id = 4,
                                           box_width = 8,
                                           main_img = "dataseticons/arda.jpg",
                                           front_title = "The Association of Religion Data Archives",
                                           back_title = "About the Data",
                                           back_content = tagList(
                                             tags$div("The",tags$a("Association of Religion Data Archives (ARDA)", href = "https://www.thearda.com/"),
                                                      "is a collection of surveys, polls,
                                                      and other data submitted by researchers to the ARDA. ARDA compiles multi-year 
                                                      data on congregations, membership, and religious preferences at the international 
                                                      and national levels. ARDA data is available at the county level and above.")
                                             )
                                             ),
                                         br(),
                                         flipBox(
                                           id = 13,
                                           box_width = 8,
                                           main_img = "dataseticons/forest.jpg",
                                           front_title = "USDA Forest Service",
                                           back_title = "About the Data",
                                           back_content = tagList(
                                             tags$div("The", tags$a("USDA Forest Service", href = "https://www.fia.fs.fed.us/tools-data/"), 
                                                      "maintains the Design and Analysis Toolkit for Inventory and Monitoring 
                                                      (DATIM) that provides modules to 
                                                      analyze the availability and sustainability of forest resources. 
                                                      Data are available annually at various geographic levels.")
                                             )
                                             ),
                                         br(),
                                         flipBox(
                                           id = 14,
                                           box_width = 8,
                                           main_img = "dataseticons/bea.jpg",
                                           front_title = "US Bureau of Economic Analysis ",
                                           back_title = "About the Data",
                                           back_content = tagList(
                                             tags$div("The", tags$a("US Bureau of Economic Analysis", href = "https://apps.bea.gov/iTable/iTable.cfm?reqid=99&step=1#reqid=99&step=1&isuri=1"), 
                                                      "produces information about the 
                                                      US gross domestic product, (GDP), foreign trade, investment and industry data. 
                                                      Its section of GDP and personal income mapping contains data on national total output produced by county for the 2001-2018 period.  ")
                                             )
                                             )
                                           ),
                                  column(4,
                                         flipBox(
                                           id = 5,
                                           box_width = 8,
                                           main_img = "dataseticons/fec.jpg",
                                           front_title = "Federal Election Commission Data",
                                           back_title = "About the Data",
                                           back_content = tagList(
                                             tags$div("The", tags$a("Federal Election Commission",href="https://www.fec.gov/"), "is a regulatory agency of US elections. It
                                                      produces datasets that encompass information about the funds raised and spent by all 
                                                      candidates and elected officials. They provide their data at the 1-year intervals,
                                                      available at the district level and above.")
                                             )
                                             ),
                                         br(),
                                         flipBox(
                                           id = 6,
                                           box_width = 8,
                                           main_img = "dataseticons/mit.jpg",
                                           front_title = "MIT Elections Lab",
                                           back_title = "About the Data",
                                           back_content = tagList(
                                             tags$div("The", tags$a("MIT Election Lab",href="https://electionlab.mit.edu/"), "provides data about voting behaviors in elections. Their 
                                                      datasets include demographic information and voting behaviors, including voter 
                                                      participation. Their data is provided for each election, at the local precinct-level 
                                                      and above.")
                                             )
                                             ),
                                         br(),
                                         flipBox(
                                           id = 7,
                                           box_width = 8,
                                           main_img = "dataseticons/usda.jpg",
                                           front_title = "National Census of Agriculture",
                                           back_title = "About the Data",
                                           back_content = tagList(
                                             tags$div("TheUnited States Department of Agriculture publishes the", tags$a("National Agricultural 
                                                                                                                         Statistics Service Census of Agriculture", href = "https://www.nass.usda.gov/AgCensus/"), "with data about demographics, agriculture, 
                                                      environment, livestock, and research. Data are provided annually and are available
                                                      at district-level geography and above.")
                                             )
                                             ),
                                         br(),
                                         flipBox(
                                           id = 8,
                                           box_width = 8,
                                           main_img = "dataseticons/dave.jpg",
                                           front_title = "Atlas of US Presidential Elections",
                                           back_title = "About the Data",
                                           back_content = tagList(
                                             tags$div(tags$a("Dave Leip’s Atlas of US Presidential Elections", href = "https://uselectionatlas.org/"), "is a public-access dataset that 
                                                      provides information on election results. The website provides data annually
                                                      on polling, predictions, endorsement, voting and electoral college outcomes 
                                                      during each election. Data are available at state-level.")
                                             )
                                             )
                                             ),
                                  column(4,
                                         flipBox(
                                           id = 9,
                                           box_width = 8,
                                           main_img = "dataseticons/urban.jpg",
                                           front_title = "Debt in America",
                                           back_title = "About the Data",
                                           back_content = tagList(
                                             tags$div("The Urban Institute's", tags$a("Debt of America", href = "https://apps.urban.org/features/debt-interactive-map/"), "is a dataset that includes information on Americans' 
                                                      financial behaviors. It is based on sampled de-identified data from 
                                                      credit bureaus, as well as on 1-year and 5-year American Community Survey estimates. 
                                                      Data are available at county-level geography and above.")
                                             )
                                             ),
                                         br(),
                                         flipBox(
                                           id = 10,
                                           box_width = 8,
                                           main_img = "dataseticons/census.jpg",
                                           front_title = "County Business Patterns",
                                           back_title = "About the Data",
                                           back_content = tagList(
                                             tags$div("The", tags$a("County Business Patterns (CBP)", href = "https://www.census.gov/programs-surveys/cbp.html"),"dataset is provided by the US Census Bureau and 
                                                      contains information on businesses at the county level. The annual data includes 
                                                      codes of each type of business, how many businesses are located in a given geography, 
                                                      and information about those businesses.")
                                             )
                                             ),
                                         br(),
                                         flipBox(
                                           id = 11,
                                           box_width = 8,
                                           main_img = "dataseticons/cdc.jpg",
                                           front_title = "Centers for Disease Control and Prevention Data",
                                           back_title = "About the Data",
                                           back_content = tagList(
                                             tags$div("Department of Health and Human Services", tags$a("Center for Disease Control and Prevention", href = "https://www.cdc.gov/")," 
                                                      provide data on health and disease prevalence. They include yearly sample data at the 
                                                      county-level on common diseases and general health statistics.")
                                             )
                                             ),
                                         br(),
                                         flipBox(
                                           id = 12,
                                           box_width = 8,
                                           main_img = "dataseticons/robert.jpg",
                                           front_title = "County Health Rankings",
                                           back_title = "About the Data",
                                           back_content = tagList(
                                             tags$div("The", tags$a("Robert Wood Johnson County Health Rankings", href = "https://www.countyhealthrankings.org/"), "data provide yearly estimates of health 
                                             indicators at the county-level. 
                                             Rankings take into account health outcomes, health behaviors, sociodemographic 
                                             characteristics, and the physical environment. The dataset aggregates county-level information from 
                                             multiple sources.")
                                           )
                                         ),
                                         br(),
                                         flipBox(
                                           id = 15,
                                           box_width = 8,
                                           main_img = "dataseticons/usgs.jpg",
                                           front_title = "US Geological Survey ",
                                           back_title = "About the Data",
                                           back_content = tagList(
                                             tags$div("The", tags$a("US Geological Survey (USGS)", href = "https://www.usgs.gov/mission-areas/water-resources"), 
                                                      "explores water conditions, including streamflow, water levels, quality, and use. 
                                              USGS collects data at approximately 1.9 million sites in all 50 states and in territories. 
                                              Data are available at site and county level.")
                                           )
                                         )
                                           )
                                             )
                                           )
                                         ),
                    
                    # BIBLIOGRAPHY CONTENT -------------------------
                    tabItem(tabName = "biblio",
                            fluidRow(
                              box(width = 12,
                                  title = "Bibliography",
                                  selectInput("topic_biblio", "Select capital:", width = "100%", choices = c(
                                    "All",
                                    "Financial",
                                    "Human",
                                    "Social",
                                    "Natural", 
                                    "Built", 
                                    "Political", 
                                    "Cultural")),
                                  DTOutput("biblio_table"))
                            )
                    ),
                    
                    # CONTACT CONTENT -------------------------
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
                            ),
                            
                            fluidRow(
                              box(width = 12,
                                  title = "Acknowledgements",
                                  p("We would like to thank our colleagues for their input and contributions to this project.", align = "left"),
                                  
                                  column(width = 3,
                                         tags$a(tags$img(src = "logo_vatech.png", width = '70%', style = "display: block; margin-left: auto; margin-right: auto; border: 0.5px solid #B4B4B4"),
                                                href = "https://ext.vt.edu/"),
                                         br(),
                                         tags$ul(em("Faculty:"),
                                                 tags$li("Susan Chen, Associate Professor, Department of Agricultural and Applied Economics"),
                                                 tags$li("Daniel Goerlich, Associate Director, Economy, Community, and Food, Virginia Cooperative Extension"),
                                                 tags$li("Matthew Holt, Professor and Department Head, Department of Agricultural and Applied Economics"),
                                                 tags$li("Ed Jones, Director, Virginia Cooperative Extension and Associate Dean, College of Agriculture and Life Sciences"),
                                                 tags$li("Michael Lambur, Associate Director, Program Development, Virginia Cooperative Extension"),
                                                 tags$li("Cathy Sutphin, Associate Director, Youth, Families, and Health, Virginia Cooperative Extension"),
                                                 style = "list-style: none; margin-left: 0px; padding-left: 0px"
                                         ),
                                         br()   
                                  ),
                                  
                                  column(width = 3,
                                         tags$a(tags$img(src = "logo_isu.png", width = '40%', style = "display: block; margin-left: auto; margin-right: auto; border: 0.5px solid #B4B4B4"), 
                                                href = "https://www.iastate.edu/"),
                                         br(),
                                         tags$ul(em("Faculty:"),
                                                 tags$li("Todd Abraham, Assistant Director of Data and Analytics for the Iowa Integrated Data System"),
                                                 tags$li("Cass Dorius, Associate Professor of Human Development and Family Studies"), 
                                                 tags$li("Shawn Dorius, Associate Professor of Sociology"),
                                                 style = "list-style: none; margin-left: 0px; padding-left: 0px"
                                         ),
                                         p(em("Students:"), "Joel Von Behren, Jessie Bustin, Grant Durbahn, 
                                           Haley Jeppson, Vikram Magal, Atefeh Rajabalizadah, Kishor Sridhar, 
                                           Katie Thompson, Matthew Voss" 
                                         ),
                                         br()
                                         ),
                                  
                                  column(width = 3,
                                         tags$a(tags$img(src = "logo_osu.jpg", width = '50%', style = "display: block; margin-left: auto; margin-right: auto; border: 0.5px solid #B4B4B4"),
                                                href = "https://oregonstate.edu/"),
                                         br(),
                                         tags$ul(em("Faculty:"),
                                                 tags$li("Shawn Irvine, Economic Development Director, City of Independence, Oregon"),
                                                 tags$li("Deborah John, Professor and Extension Specialist, College of Public Health and Human Sciences"),
                                                 tags$li("Stuart Reitz, Professor and Director, Malheur Experiment Station"),
                                                 tags$li("Lindsey Shirley, Associate Provost, University Extension & Engagement"),
                                                 tags$li("Brett M. Tyler, Director of the Center for Genome Research and Biocomputing and Stewart Professor of Gene Research"),
                                                 style = "list-style: none; margin-left: 0px; padding-left: 0px"
                                         )
                                  ),
                                  
                                  column(width = 3,
                                         tags$a(tags$img(src = "logo_bii.png", width = '70%', style = "display: block; margin-left: auto; margin-right: auto; border: 0.5px solid #B4B4B4"), 
                                                href = "https://biocomplexity.virginia.edu/"),
                                         br(),
                                         tags$ul(em("Faculty:"),
                                                 tags$li("Sallie Keller, Division Director, Distinguished Professor in Biocomplexity, and Professor of Public Health Sciences, School of Medicine"),
                                                 tags$li("Brandon Kramer, Postdoctoral Research Associate"),
                                                 tags$li("Vicki Lancaster, Principal Scientist"),
                                                 tags$li("Kathryn Linehan, Research Scientist"),
                                                 tags$li("Sarah McDonald, Research Assistant"),
                                                 tags$li("Cesar Montalvo, Postdoctoral Research Associate"),
                                                 tags$li("Teja Pristavec, Research Assistant Professor"),
                                                 tags$li("Stephanie Shipp, Deputy Division Director and Research Professor"),
                                                 style = "list-style: none; margin-left: 0px; padding-left: 0px"
                                         ),
                                         p(em("Students:"), "Riya Berry, Tasfia Chowdhury, Martha Czernuszenko,
                                           Lara Haase, Saimun Habib, Owen Hart, Vatsala Ramanan, Morgan Stockham"
                                         )
                                         
                                         )
                                  
                                  )
                              
                                  )
                            
                            )      
                                           )
                                           )
                                  )


#
# SERVER ----------------------------------------------------------------------------------------------------
#

server <- function(input, output, session) {
  # Plot colors --------------------------
  cbGreens <- c("#F7F7F7", "#D9F0D3", "#ACD39E", "#5AAE61", "#1B7837", "grey")
  cbGreens2 <- c("#4E5827", "#6E752A", "#959334", "#C3B144", "#F9F1CB", "#EB8E38", "#C96918")
  cbGreensAlt <- c("#F7F7F7", "#D9F0D3", "#ACD39E", "#5AAE61", "#1B7837", 
                   "#F7F7F7", "#D9F0D3", "#ACD39E", "#5AAE61", "#1B7837",
                   "#F7F7F7", "#D9F0D3", "#ACD39E", "grey")
  cbBrowns <- c("#FFF4A2", "#E9DC7A", "#D2C351", "#BCAB29", "#A59200", "grey")
  
  # legend image -------------------------
  
  # output$legend <- renderImage({
  #   # When input$n is 1, filename is ./images/image1.jpeg
  #   filename <- normalizePath(file.path('./www',
  #                                       paste('legend_irr', '.png', sep='')))
  #   
  #   # Return a list containing the filename
  #   list(src = filename)
  # }, deleteFile = FALSE)
  
  
  # Info button content ---------------------
  observeEvent(input$infobutton_fin, {
    shinyalert(text = includeHTML("index_interpretation.html"), html = TRUE, type = "info", size = "l", animation = FALSE,
               closeOnEsc = TRUE, closeOnClickOutside = TRUE, showConfirmButton = TRUE, confirmButtonText = "Close")
  })
  observeEvent(input$infobutton_hum, {
    shinyalert(text = includeHTML("index_interpretation.html"), html = TRUE, type = "info", size = "l", animation = FALSE,
               closeOnEsc = TRUE, closeOnClickOutside = TRUE, showConfirmButton = TRUE, confirmButtonText = "Close")
  })
  observeEvent(input$infobutton_soc, {
    shinyalert(text = includeHTML("index_interpretation.html"), html = TRUE, type = "info", size = "l", animation = FALSE,
               closeOnEsc = TRUE, closeOnClickOutside = TRUE, showConfirmButton = TRUE, confirmButtonText = "Close")
  })
  observeEvent(input$infobutton_nat, {
    shinyalert(text = includeHTML("index_interpretation.html"), html = TRUE, type = "info", size = "l", animation = FALSE,
               closeOnEsc = TRUE, closeOnClickOutside = TRUE, showConfirmButton = TRUE, confirmButtonText = "Close")
  })
  observeEvent(input$infobutton_cult, {
    shinyalert(text = includeHTML("index_interpretation_cultural.html"), html = TRUE, type = "info", size = "l", animation = FALSE,
               closeOnEsc = TRUE, closeOnClickOutside = TRUE, showConfirmButton = TRUE, confirmButtonText = "Close")
  })
  observeEvent(input$infobutton_built, {
    shinyalert(text = includeHTML("index_interpretation.html"), html = TRUE, type = "info", size = "l", animation = FALSE,
               closeOnEsc = TRUE, closeOnClickOutside = TRUE, showConfirmButton = TRUE, confirmButtonText = "Close")
  })
  observeEvent(input$pcindex_info, {
    shinyalert(text = includeHTML("index_interpretation.html"), html = TRUE, type = "info", size = "l", animation = FALSE,
               closeOnEsc = TRUE, closeOnClickOutside = TRUE, showConfirmButton = TRUE, confirmButtonText = "Close")
  })
  
  
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
                marker = list(symbol = "asterisk", color = ~irr2010_discretize),
                hoverinfo = "y",
                name = "") %>%
      add_markers(x = ~jitter(as.numeric(group), amount = 0.1), 
                  y = ~myvar, 
                  color = ~irr2010_discretize,
                  marker = list(size = 8, line = list(width = 1, color = "#3C3C3C")),
                  hoverinfo = "text",
                  text = ~paste0("Rurality Index: ", round(irr2010, 2),
                                 "<br>County: ", county),
                  showlegend = TRUE) %>%
      layout(title = "",
             legend = list(title = list(text = "<b>Index of Relative\nRurality</b>")),
             xaxis = list(title = myvarlabel,
                          zeroline = FALSE,
                          showticklabels = FALSE),
             yaxis = list(title = "",
                          zeroline = FALSE,
                          hoverformat = ".2f")) %>%
      layout(
        images = list(
          source = raster2uri(as.raster(legend_irr)),
          x = 1.42, y = 0, 
          sizex = 0.4, sizey = 0.4,
          xref = "paper", yref = "paper", 
          xanchor = "right", yanchor = "bottom"
        ),
        margin = list(t = 50)
      )
    
  }
  
  # Function for indicator maps: POSITIVE ------------------------------------
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
                title = "Quintile Range",
                opacity = 0.7,
                na.label = "Not Available",
                labFormat = function(type, cuts, p) {
                  n = length(cuts)
                  paste0("[", round(cuts[-n], 2), " &ndash; ", round(cuts[-1], 2), ")")
                })
    
  }
  
  # Function for indicator maps: NEGATIVE ------------------------------------
  create_indicator_neg <- function(data, myvar, myvarlabel) {
    
    pal <- colorQuantile(cbBrowns[1:5], domain = myvar, probs = seq(0, 1, length = 6), 
                         na.color = cbBrowns[6], right = TRUE)
    
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
                title = "Value",
                opacity = 0.7,
                na.label = "Not Available",
                labFormat = function(type, cuts, p) {
                  n = length(cuts)
                  paste0("[", round(cuts[-n], 2), " &ndash; ", round(cuts[-1], 2), ")")
                })
    
  }
  
  # Function for indicator maps: POSITIVE FOR BINS ---------------------------------------
  create_indicator_bins <- function(data, myvar, myvarlabel) {
    
    pal <- colorBin(palette = cbGreens[1:5], 
                    domain = myvar, 
                    bins = 5, 
                    na.color = cbGreens[6]
    )
    
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
                title = "Value By Group",
                opacity = 0.7,
                na.label = "Not Available",
                labFormat = function(type, cuts, p) {
                  n = length(cuts)
                  paste0("[", round(cuts[-n], 2), " &ndash; ", round(cuts[-1], 2), ")")
                })
    
  }
  
  # Function for index maps: POSITIVE ---------------------------------------
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
                title = "Index Value [1-5]",
                opacity = 0.7,
                na.label = "Not Available")
  }
  
  # Function for index maps: NEGATIVE ---------------------------------------
  create_index_neg <- function(data, myvar, myvarlabel) {
    
    pal <- colorNumeric(cbBrowns[1:5], domain = myvar, na.color = cbBrowns[6])
    
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
                title = "Index Value [1-5]",
                opacity = 0.7,
                na.label = "Not Available")
  }
  

  
  
  # Switches
  fin_data <- reactive({datafin %>% filter(state == input$fin_whichstate)})
  hum_data <- reactive({datahum %>% filter(state == input$hum_whichstate)})
  soc_data <- reactive({datasoc %>% filter(state == input$soc_whichstate)})
  pol_data <- reactive({datapol %>% filter(state == input$pol_whichstate)})
  nat_data <- reactive({datanat %>% filter(state == input$nat_whichstate)})
  cult_data <- reactive({datacult %>% filter(state == input$cult_whichstate)})
  built_data <- reactive({databuilt %>% filter(state == input$built_whichstate)})
  
  #
  # Capital Index Maps ------------------------------------------------
  #
  
  #
  # Financial Index Maps -------------------------------------------------------
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
    create_index_neg(hum_data(), hum_data()$hum_index_despair, "Despair Index")
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
    create_index_neg(soc_data(), soc_data()$soc_index_isol, "Social Isolation Index")
  })
  
  #
  # Natural Index Maps--------------------------------------------------
  #
  output$plot_nat_index_land <- renderLeaflet({
    create_index(nat_data(), nat_data()$nat_index_LAND, "Land Resources Index")
  })
  
  output$plot_nat_index_water <- renderLeaflet({
    create_index(nat_data(), nat_data()$nat_index_WATER, "Water Resources Index")
  })
  
  output$plot_nat_index_air <- renderLeaflet({
    create_index_neg(nat_data(), nat_data()$nat_index_AIR, "Air Resources Index")
  })
    
  output$plot_nat_index_produc <- renderLeaflet({
    
    pal <- colorNumeric(cbGreens[1:5], domain = nat_data()$nat_index_DEPEND, na.color = cbGreens[6])
    
    labels <- lapply(
      paste("<strong>Area: </strong>",
            nat_data()$NAME.y,
            "<br />",
            "<strong>", "Natural Capital Dependence Index", ": </strong>",
            round(nat_data()$nat_index_DEPEND, 2)),
      htmltools::HTML
    )
    
    leaflet(data = nat_data()) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(fillColor = ~pal(nat_data()$nat_index_DEPEND), 
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
                values =  ~(nat_data()$nat_index_DEPEND),
                title = "%GDP That Depends on<br>Natural Resources",
                opacity = 0.7,
                na.label = "Not Available")
  })
  
  output$plot_nat_index_vulner <- renderLeaflet({
    create_index_neg(nat_data(), nat_data()$nat_index_VULNER, "Vulnerability Index")
  })
  
  #
  # Political Index Maps--------------------------------------------------
  #
  output$plot_political_index <- renderLeaflet({
    create_index(pol_data(), pol_data()$pol_index, "Political index")
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
    
    create_indicator_neg(fin_data(), data_var, var_label)
  })   
  
  output$plotly_fin_finwell_pov <- renderPlotly({
    
    data_var <- fin_data()$fin_pctinpov
    var_label <- "Percent with Income Below Poverty Level in Last 12 Months"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_finwell_pov <- renderLeaflet({
    
    data_var <- fin_data()$fin_pctinpov
    var_label <- "Percent with Income Below Poverty Level in Last 12 Months"
    
    create_indicator_neg(fin_data(), data_var, var_label)
  })   
  
  output$plotly_fin_finwell_assist <- renderPlotly({
    
    data_var <- fin_data()$fin_pctassist
    var_label <- "Percent Households Receiving Public Assistance or SNAP"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_finwell_assist <- renderLeaflet({
    
    data_var <- fin_data()$fin_pctassist
    var_label <- "Percent Households Receiving Public Assistance or SNAP"
    
    create_indicator_neg(fin_data(), data_var, var_label)
  })   
  
  output$plotly_fin_finwell_ssi <- renderPlotly({
    
    data_var <- fin_data()$fin_pctssi
    var_label <- "Percent Households Receiving Supplemental Security Income"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_finwell_ssi <- renderLeaflet({
    
    data_var <- fin_data()$fin_pctssi
    var_label <- "Percent Households Receiving Supplemental Security Income"
    
    create_indicator_neg(fin_data(), data_var, var_label)
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
    
    create_indicator_neg(fin_data(), data_var, var_label)
  }) 
  
  output$plotly_fin_finwell_debtcol <- renderPlotly({
    
    data_var <- fin_data()$fin_pctdebtcol
    var_label <- "Share of People with a Credit Bureau Record Who Have Any Debt in Collections"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_finwell_debtcol <- renderLeaflet({
    
    data_var <- fin_data()$fin_pctdebtcol
    var_label <- "Share of People with a Credit Bureau Record Who Have Any Debt in Collections"
    
    create_indicator_neg(fin_data(), data_var, var_label)
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
    
    create_indicator_neg(fin_data(), data_var, var_label)
  })  
  
  output$plotly_fin_employ_unempcovid <- renderPlotly({
    
    data_var <- fin_data()$fin_unempcovid
    var_label <- "Unemployment Rate During COVID"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_employ_unempcovid <- renderLeaflet({
    
    data_var <- fin_data()$fin_unempcovid
    var_label <- "Unemployment Rate During COVID"
    
    create_indicator_neg(fin_data(), data_var, var_label)
  })  
  
  output$plotly_fin_employ_commute <- renderPlotly({
    
    data_var <- fin_data()$fin_pctcommute
    var_label <- "Percent Commuting 30min+"
    
    create_boxplot(fin_data(), data_var, var_label)
  })
  
  
  output$plot_fin_employ_commute <- renderLeaflet({
    
    data_var <- fin_data()$fin_pctcommute
    var_label <- "Percent Commuting 30min+"
    
    create_indicator_neg(fin_data(), data_var, var_label)
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
    
    create_indicator_neg(hum_data(), data_var, var_label)
  })  
  
  output$plotly_hum_health_poorment <- renderPlotly({
    
    data_var <- hum_data()$hum_numpoormental
    var_label <- "Average Number of Reported Poor Physical Mental Days in a Month"
    
    create_boxplot(hum_data(), data_var, var_label)
  })
  
  output$plot_hum_health_poorment <- renderLeaflet({
    
    data_var <- hum_data()$hum_numpoormental
    var_label <- "Average Number of Reported Poor Physical Mental Days in a Month"
    
    create_indicator_neg(hum_data(), data_var, var_label)
  })  
  
  output$plotly_hum_health_nophys <- renderPlotly({
    
    data_var <- hum_data()$hum_pctnophys
    var_label <- "Percentage of Adults that Report No Leisure-time Physical Activity"
    
    create_boxplot(hum_data(), data_var, var_label)
  })
  
  
  output$plot_hum_health_nophys <- renderLeaflet({
    
    data_var <- hum_data()$hum_pctnophys
    var_label <- "Percentage of Adults that Report No Leisure-time Physical Activity"
    
    create_indicator_neg(hum_data(), data_var, var_label)
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
    
    create_indicator_neg(hum_data(), data_var, var_label)
  })  
  
  output$plotly_hum_childcare_womenhs <- renderPlotly({
    
    data_var <- hum_data()$hum_pctFnohs
    var_label <- "Percent of Women Who did not Receive HS Diploma or Equivalent"
    
    create_boxplot(hum_data(), data_var, var_label)
  })
  
  output$plot_hum_childcare_womenhs <- renderLeaflet({
    
    data_var <- hum_data()$hum_pctFnohs
    var_label <- "Percent of Women Who did not Receive HS Diploma or Equivalent"
    
    create_indicator_neg(hum_data(), data_var, var_label)
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
    
    create_indicator_neg(hum_data(), data_var, var_label)
  }) 
  
  output$plotly_hum_despair_unemp <- renderPlotly({
    
    data_var <- hum_data()$hum_pctunemp
    var_label <- "Percent Population in Labor Force Unemployed"
    
    create_boxplot(hum_data(), data_var, var_label)
  })
  
  output$plot_hum_despair_unemp <- renderLeaflet({
    
    data_var <- hum_data()$hum_pctunemp
    var_label <- "Percent Population in Labor Force Unemployed"
    
    create_indicator_neg(hum_data(), data_var, var_label)
  }) 
  
  output$plotly_hum_despair_whitemhs <- renderPlotly({
    
    data_var <- hum_data()$hum_whitemhs
    var_label <- "Percent White Men with High School Education or Lower"
    
    create_boxplot(hum_data(), data_var, var_label)
  })
  
  output$plot_hum_despair_whitemhs <- renderLeaflet({
    
    data_var <- hum_data()$hum_whitemhs
    var_label <- "Percent White Men with High School Education or Lower"
    
    create_indicator_neg(hum_data(), data_var, var_label)
  }) 
  
  output$plotly_hum_despair_aggdeaths <- renderPlotly({
    
    data_var <- hum_data()$hum_ageratedeaths
    var_label <- "Age-adjusted Rate of Alcohol, Overdose, and Suicide Deaths Over 9 Years per 100,000 Population"
    
    create_boxplot(hum_data(), data_var, var_label)
  })
  
  output$plot_hum_despair_aggdeaths <- renderLeaflet({
    
    data_var <- hum_data()$hum_ageratedeaths
    var_label <- "Age-adjusted Rate of Alcohol, Overdose, and Suicide Deaths Over 9 Years per 100,000 Population"
    
    create_indicator_neg(hum_data(), data_var, var_label)
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
    
    create_indicator_neg(soc_data(), data_var, var_label)
  }) 
  
  output$plotly_soc_rel_violentcrimes <- renderPlotly({
    
    data_var <- soc_data()$soc_violcrime
    var_label <- "Number of Violent Crimes per 100,000 Population"
    
    create_boxplot(soc_data(), data_var, var_label)
  })
  
  output$plot_soc_rel_violentcrimes <- renderLeaflet({
    
    data_var <- soc_data()$soc_violcrime
    var_label <- "Number of Violent Crimes per 100,000 Population"
    
    create_indicator_neg(soc_data(), data_var, var_label)
  }) 
  
  output$plotly_soc_rel_grandparent <- renderPlotly({
    
    data_var <- soc_data()$soc_grandp
    var_label <- "Percent Grandparent Householders Responsible for Own Grandchildren"
    
    create_boxplot(soc_data(), data_var, var_label)
  })
  
  output$plot_soc_rel_grandparent <- renderLeaflet({
    
    data_var <- soc_data()$soc_grandp
    var_label <- "Percent Grandparent Householders Responsible for Own Grandchildren"
    
    create_indicator_neg(soc_data(), data_var, var_label)
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
    
    create_indicator_neg(soc_data(), data_var, var_label)
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
    
    create_indicator_neg(soc_data(), data_var, var_label)
  }) 
  
  output$plotly_soc_iso_english <- renderPlotly({
    
    data_var <- soc_data()$soc_limiteng
    var_label <- "Percent of Residents that <br>are not Proficient in Speaking English"
    
    create_boxplot(soc_data(), data_var, var_label)
  })
  
  output$plot_soc_iso_english <- renderLeaflet({
    
    data_var <- soc_data()$soc_limiteng
    var_label <- "Percent of Residents that are not Proficient in Speaking English"
    
    create_indicator_neg(soc_data(), data_var, var_label)
  }) 
  
  output$plotly_soc_iso_65alone <- renderPlotly({
    
    data_var <- soc_data()$soc_65alone
    var_label <- "Percent Population <br>Over 65 Living Alone"
    
    create_boxplot(soc_data(), data_var, var_label)
  })
  
  output$plot_soc_iso_65alone <- renderLeaflet({
    
    data_var <- soc_data()$soc_65alone
    var_label <- "Percent Population Over 65 Living Alone"
    
    create_indicator_neg(soc_data(), data_var, var_label)
  }) 
  
  output$plotly_soc_iso_mentalhealth <- renderPlotly({
    
    data_var <- soc_data()$soc_freqmental
    var_label <- "Percent Population Reporting <br>More Than 14 Poor Mental Health <br>Days per Month (Frequent Mental Distress)"
    
    create_boxplot(soc_data(), data_var, var_label)
  })
  
  output$plot_soc_iso_mentalhealth <- renderLeaflet({
    
    data_var <- soc_data()$soc_freqmental
    var_label <- "Percent Population Reporting<br>More Than 14 Poor Mental Health <br>Days per Month (Frequent Mental Distress)"
    
    create_indicator_neg(soc_data(), data_var, var_label)
  }) 
  
  output$plotly_soc_iso_suicide <- renderPlotly({
    
    data_var <- soc_data()$soc_suicrate
    var_label <- "Number of Suicides per 1,000 Population"
    
    create_boxplot(soc_data(), data_var, var_label)
  })
  
  output$plot_soc_iso_suicide <- renderLeaflet({
    
    data_var <- soc_data()$soc_suicrate
    var_label <- "Number of Suicides per 1,000 Population"
    
    create_indicator_neg(soc_data(), data_var, var_label)
  }) 
  
  # Natural - Land - Boxplot and Map ------------------
  
  output$plotly_nat_quantres_farmland <- renderPlotly({
    
    data_var <- nat_data()$nat_pctagacres
    var_label <- "Percent of County Area in Farmland"
    
    create_boxplot(nat_data(), data_var, var_label)
  })
  
  #new forestland
  output$plotly_nat_quantres_forestland <- renderPlotly({
    
    data_var <- nat_data()$nat_forestlandpc
    var_label <- "Percent of County Area in Forestland"
    
    create_boxplot(nat_data(), data_var, var_label)
  })
  
  ##timberland
  output$plotly_nat_quantres_timberland <- renderPlotly({
    
    data_var <- nat_data()$nat_timberland_sqmiles
    var_label <- "Percent of County Area in Timberland"
    
    create_boxplot(nat_data(), data_var, var_label)
  })
  
  
  output$plot_nat_quantres_farmland <- renderLeaflet({
    
    data_var <- nat_data()$nat_pctagacres
    var_label <- "Percent of County Area in Farmland"
    
    create_indicator(nat_data(), data_var, var_label)
  }) 
  
  #new forestland
  output$plot_nat_quantres_forestland <- renderLeaflet({
    
    data_var <- nat_data()$nat_forestlandpc
    var_label <- "Percent of County Area in Forestland"
    
    create_indicator(nat_data(), data_var, var_label)
  }) 
  
  #timberland
  output$plot_nat_quantres_timberland <- renderLeaflet({
    
    data_var <- nat_data()$nat_timberland_sqmiles
    var_label <- "Area (squared miles) in Timberland"
    
    create_indicator(nat_data(), data_var, var_label)
  }) 
  
  
  # Natural - Water - Boxplot and Map   ------------------
  output$plotly_nat_quantres_water <- renderPlotly({
    
    data_var <- nat_data()$nat_pctwater
    var_label <- "Percent of County Area in Water"
    
    create_boxplot(nat_data(), data_var, var_label)
  })
  #new
  output$plotly_nat_water_with <- renderPlotly({
    
    data_var <- nat_data()$nat_water_with
    var_label <- "Total Water Withdrawals, Millions of Gallons per Day"
    
    create_boxplot(nat_data(), data_var, var_label)
  })
  #irrigation
  output$plotly_nat_irrig_water <- renderPlotly({
    
    data_var <- nat_data()$nat_irrig_water
    var_label <- "Water Withdrawals for Irrigation, Millions of Gallons per Day"
    
    create_boxplot(nat_data(), data_var, var_label)
  })
  #water use
  output$plotly_nat_water_percapita_galday <- renderPlotly({
    
    data_var <- nat_data()$nat_water_percapita_galday
    var_label <- "Domestic Water Use, Gallons per Day"
    
    create_boxplot(nat_data(), data_var, var_label)
  })
  
  
  output$plot_nat_quantres_water <- renderLeaflet({
    
    data_var <- nat_data()$nat_pctwater
    var_label <- "Percent of County Area in Water"
    
    create_indicator(nat_data(), data_var, var_label)
  }) 
  
  #new water withdrawals
  output$plot_nat_water_with <- renderLeaflet({
    
    data_var <- nat_data()$nat_water_with
    var_label <- "Total Water Withdrawals (Surface and Ground), Millions of Gallons per Day"
    
    create_indicator(nat_data(), data_var, var_label)
  }) 
  
  #irrigation
  output$plot_nat_irrig_water <- renderLeaflet({
    
    data_var <- nat_data()$nat_irrig_water
    var_label <- "Water Withdrawals for Irrigation, Millions of Gallons per Day"
    
    create_indicator(nat_data(), data_var, var_label)
  }) 
  
  #water use
  output$plot_nat_water_percapita_galday <- renderLeaflet({
    
    data_var <- nat_data()$nat_water_percapita_galday
    var_label <- "Domestic Water Use, Gallons per Day"
    
    create_indicator(nat_data(), data_var, var_label)
  }) 
  
  
  #
  # Natural - Air - Boxplot and Map  ------------------
  
  output$plotly_nat_qualres_part <- renderPlotly({
    
    data_var <- nat_data()$nat_particulatedensity
    var_label <- "Average Daily Density of Fine Particulate Matter"
    
    create_boxplot(nat_data(), data_var, var_label)
  })
  
  #air concentration
  output$plotly_nat_airconcenpollution <- renderPlotly({
    
    data_var <- nat_data()$nat_airpollution_conc_benz
    var_label <- "Annual Average Air Concentration Estimates In Microgram Per Cubic Meter"
    
    create_boxplot(nat_data(), data_var, var_label)
  })
  
  #cancer risk
  output$plotly_nat_cancerisk <- renderPlotly({
    
    data_var <- nat_data()$nat_cancer_risk_benz_estpm
    var_label <- "Annual Average Cancer Risk Estimates Per Million (Pollutant: Benzene) "
    
    create_boxplot(nat_data(), data_var, var_label)
  })  
  
  #new air concentration
  output$plot_nat_airpollutionconc <- renderLeaflet({
    
    data_var <- nat_data()$nat_airpollution_conc_benz
    var_label <- "Annual Average Air Concentration Estimates In Microgram Per Cubic Meter"
    
    create_indicator_neg(nat_data(), data_var, var_label)
  }) 
  
  output$plot_nat_qualres_part <- renderLeaflet({
    
    data_var <- nat_data()$nat_particulatedensity
    var_label <- "Average Daily Density of Fine Particulate Matter"
    
    create_indicator_neg(nat_data(), data_var, var_label)
  }) 
  
  #cancer risk
  output$plot_nat_cancerisk <- renderLeaflet({
    
    data_var <- nat_data()$nat_cancer_risk_benz_estpm
    var_label <- "Annual Average Cancer Risk Estimates Per Million (Pollutant: Benzene)"
    
    create_indicator_neg(nat_data(), data_var, var_label)
  }) 
  
  # Natural - Vulnerability - Boxplot and Map  ------------------
  
  #vulnerability flood
  output$plotly_nat_flood_haz_pcarea <- renderPlotly({
    
    data_var <- nat_data()$nat_flood_haz_pcarea
    var_label <- "Percent Area"
    
    create_boxplot(nat_data(), data_var, var_label)
  })
  
  #vulneratility fire
  output$plotly_nat_firevulnerab_pop <- renderPlotly({
    
    data_var <- nat_data()$nat_firevulnerab_pop
    var_label <- "Population Vulnerable"
    
    create_boxplot(nat_data(), data_var, var_label)
  })
  
  #vulnerability heat curr
  output$plotly_nat_ext_heatdays <- renderPlotly({
    
    data_var <- nat_data()$nat_ext_heatdays
    var_label <- "Number of Extreme Heat Days"
    
    create_boxplot(nat_data(), data_var, var_label)
  })
  
  #vulnerability heat projected
  output$plotly_nat_ext_heatdays_proj <- renderPlotly({
    
    data_var <-  as.numeric(nat_data()$nat_ext_heatdays_proj)  
    var_label <- "Number of Future Extreme Heat Days"
    
    create_boxplot(nat_data(), data_var, var_label)
  })
  
  #vulnerability flood
  output$plot_nat_flood_haz_pcarea <- renderLeaflet({
    
    data_var <- nat_data()$nat_flood_haz_pcarea
    var_label <- "Percent Area"
    
    create_indicator_neg(nat_data(), data_var, var_label)
  }) 
  
  #vulnerability fire
  output$plot_nat_firevulnerab_pop <- renderLeaflet({
    
    data_var <- nat_data()$nat_firevulnerab_pop
    var_label <- "Population Vulnerable"
    
    create_indicator_neg(nat_data(), data_var, var_label)
  }) 
  
  #vulnerability heat curr
  output$plot_nat_ext_heatdays <- renderLeaflet({
    
    data_var <- nat_data()$nat_ext_heatdays
    var_label <- "Number of Extreme Heat Days "
    
    create_indicator_neg(nat_data(), data_var, var_label)
  }) 
  
  #vulnerability heat projected
  output$plot_nat_ext_heatdays_proj <- renderLeaflet({
    
    data_var <- as.numeric(nat_data()$nat_ext_heatdays_proj) 
    var_label <- "Number of Future Extreme Heat Days "
    
    create_indicator_neg(nat_data(), data_var, var_label)
  }) 
  
  
  # Natural - GDP Dependence - Boxplot and Map  ----------------
  
  #ag gdp
  output$plotly_nat_agric_gdp <- renderPlotly({
    
    data_var <- nat_data()$nat_agric_gdp
    var_label <- "Percentage of Agricultural GDP"
    
    create_boxplot(nat_data(), data_var, var_label)
  })
  
  #gdp mining
  output$plotly_nat_mining_gdp <- renderPlotly({
    
    data_var <- nat_data()$nat_mining_gdp
    var_label <- "Percentage of Mining GDP "
    
    create_boxplot(nat_data(), data_var, var_label)
  })
  
  
  #gdp ag
  output$plot_nat_agric_gdp <- renderLeaflet({
    
    data_var <- nat_data()$nat_agric_gdp
    var_label <- "Percentage of Agricultural GDP"
    
    create_indicator(nat_data(), data_var, var_label)
  }) 
  
  #gdp mining
  output$plot_nat_mining_gdp <- renderLeaflet({
    
    #data_var <- na.omit(nat_data()$nat_mining_gdp)
    data_var <- nat_data()$nat_mining_gdp 
    var_label <- "Percentage of Mining GDP"
    
    create_indicator(nat_data(), data_var, var_label)
  }) 
  
  #
  # Political - Contributions - Boxplot and Map ------------------
  #     
  
  output$leaflet_contrib <- renderLeaflet({
    
    data_var <- pol_data()$pol_contrib
    var_label <- "Contributors per 1000 people"
    
    create_indicator(pol_data(), data_var, var_label)
  }) 
  
  output$plotly_contrib <- renderPlotly({
    
    data_var <- pol_data()$pol_contrib
    var_label <- "Contributors per 1000 people"
    
    create_boxplot(pol_data(), data_var, var_label)
  })
  
  #
  # Political - Organizations - Boxplot and Map ------------------
  #     
  
  output$leaflet_organization <- renderLeaflet({
    
    data_var <- pol_data()$pol_orgs
    var_label <- "Organizations per 1000 people"
    
    create_indicator(pol_data(), data_var, var_label)
  }) 
  
  output$plotly_organization <- renderPlotly({
    
    data_var <- pol_data()$pol_orgs
    var_label <- "Organizations per 1000 people"
    
    create_boxplot(pol_data(), data_var, var_label)
  })
  
  #
  # Political - Voter turnout - Boxplot and Map ------------------
  #     
  
  output$leaflet_voters <- renderLeaflet({
    
    data_var <- pol_data()$pol_voterturnout
    var_label <- "Voter Turnout"
    
    create_indicator(pol_data(), data_var, var_label)
  }) 
  
  output$plotly_voters <- renderPlotly({
    
    data_var <- pol_data()$pol_voterturnout
    var_label <- "Voter Turnout"
    
    create_boxplot(pol_data(), data_var, var_label)
  })
  
  #
  # Political Assets ------------------
  #     
  
  # LAW ENFORCEMENT
  output$political_dom_law <- renderPlot({
    data <- read_csv("data/pol_final_2.csv") 
    data <- data %>% filter(dom=="LawEnforcement")
    
    # Set a number of 'empty bar' to add at the end of each group
    empty_bar <- 3
    to_add <- data.frame( matrix(NA, empty_bar*nlevels(data$group), ncol(data)) )
    colnames(to_add) <- colnames(data)
    to_add$group <- rep(levels(data$group), each=empty_bar)
    data <- rbind(data, to_add)
    data <- data %>% arrange(group)
    data$id <- seq(1, nrow(data))
    
    # Get the name and the y position of each label
    label_data <- data
    number_of_bar <- nrow(label_data)
    angle <- 90 - 360 * (label_data$id-0.5) /number_of_bar     # I substract 0.5 because the letter must have the angle of the center of the bars. Not extreme right(1) or extreme left (0)
    label_data$hjust <- ifelse( angle < -90, 1, 0)
    label_data$angle <- ifelse(angle < -90, angle+180, angle)
    
    # prepare a data frame for base lines
    base_data <- data %>% 
      group_by(group) %>% 
      summarize(start=min(id), end=max(id) ) %>% 
      rowwise() %>% 
      mutate(title=mean(c(start, end)))
    
    # prepare a data frame for grid (scales)
    grid_data <- base_data
    grid_data$end <- grid_data$end[ c( nrow(grid_data), 1:nrow(grid_data)-1)] + 1
    grid_data$start <- grid_data$start - 1
    grid_data <- grid_data[-1,]
    
    ##conditional for format of justification of name
    if (length(unique(data$group))==4) {
      arr<- c(1,1,0,0)
    } else if (length(unique(data$group))==3) {
      arr<-c(1,0.3,0)
    } else if (length(unique(data$group))==2) {
      arr<-c(1,0)
    }
    
    # Make the plot
    ggplot(data, aes(x=as.factor(id), y=value, fill=group), width=800, height = 800) +       # Note that id is a factor. If x is numeric, there is some space between the first bar
      
      #add grid lines
      geom_hline(yintercept=0, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.20, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.40, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.60, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.80, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=1, color = "gray", size=0.2, alpha=1)+
      
      geom_bar(aes(x=as.factor(id), y=value, fill=group), stat="identity", alpha=0.5) +
      scale_fill_manual(values=c("#9FBE7A","#60999A","#31596E","#F9F1CB")) +
      
      # Add text showing the value of each 100/75/50/25 lines
      annotate("text", x = rep(0, 6), y = c(0.0, 0.20, 0.40, 0.60, 0.80, 1.00), label = c("0.0","0.20", "0.40", "0.60", "0.80", "1.00") , color="black", size=3 , angle=0, fontface="bold", hjust=0) +
      
      geom_bar(aes(x=as.factor(id), y=value, fill=group), stat="identity", alpha=0.5) +
      ylim(-1.0, 1.2) +
      theme_minimal() +
      theme(
        legend.position = "none",
        axis.text = element_blank(),
        axis.title = element_blank(),
        panel.grid = element_blank(),
        plot.margin = unit(rep(-1,4), "cm") 
      ) +
      coord_polar() + 
      geom_text(data=label_data, aes(x=id, y=value+0.10, label=individual, hjust=hjust), color="black", fontface="bold",alpha=0.6, size=4, angle= label_data$angle, inherit.aes = FALSE ) +
      
      
      # Add base line information
      geom_segment(data=base_data, aes(x = start, y = -0.1, xend = end, yend = -0.1), colour = "black", alpha=0.8, size=0.6 , inherit.aes = FALSE )  +
      geom_text(data=base_data, aes(x = title, y = -0.2, label=group), hjust=c(arr), colour = "black", alpha=1, size=4, fontface="bold", inherit.aes = FALSE)
  })
  
  
  # EDUCATION
  output$political_dom_edu <- renderPlot({
    data <- read_csv("data/pol_final_2.csv") 
    data <- data %>% filter(dom=="Education")
    
    # Set a number of 'empty bar' to add at the end of each group
    empty_bar <- 3
    to_add <- data.frame( matrix(NA, empty_bar*nlevels(data$group), ncol(data)) )
    colnames(to_add) <- colnames(data)
    to_add$group <- rep(levels(data$group), each=empty_bar)
    data <- rbind(data, to_add)
    data <- data %>% arrange(group)
    data$id <- seq(1, nrow(data))
    
    # Get the name and the y position of each label
    label_data <- data
    number_of_bar <- nrow(label_data)
    angle <- 90 - 360 * (label_data$id-0.5) /number_of_bar     # I substract 0.5 because the letter must have the angle of the center of the bars. Not extreme right(1) or extreme left (0)
    label_data$hjust <- ifelse( angle < -90, 1, 0)
    label_data$angle <- ifelse(angle < -90, angle+180, angle)
    
    # prepare a data frame for base lines
    base_data <- data %>% 
      group_by(group) %>% 
      summarize(start=min(id), end=max(id) ) %>% 
      rowwise() %>% 
      mutate(title=mean(c(start, end)))
    
    # prepare a data frame for grid (scales)
    grid_data <- base_data
    grid_data$end <- grid_data$end[ c( nrow(grid_data), 1:nrow(grid_data)-1)] + 1
    grid_data$start <- grid_data$start - 1
    grid_data <- grid_data[-1,]
    
    ##conditional for format of justification of name
    if (length(unique(data$group))==4) {
      arr<- c(1,1,0,0)
    } else if (length(unique(data$group))==3) {
      arr<-c(1,0.3,0)
    } else if (length(unique(data$group))==2) {
      arr<-c(1,0)
    }
    
    # Make the plot
    ggplot(data, aes(x=as.factor(id), y=value, fill=group), width=800, height = 800) +       # Note that id is a factor. If x is numeric, there is some space between the first bar
      
      #add grid lines
      geom_hline(yintercept=0, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.20, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.40, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.60, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.80, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=1, color = "gray", size=0.2, alpha=1)+
      
      geom_bar(aes(x=as.factor(id), y=value, fill=group), stat="identity", alpha=0.5) +
      scale_fill_manual(values=c("#9FBE7A","#60999A","#31596E","#F9F1CB")) +
      
      # Add text showing the value of each 100/75/50/25 lines
      annotate("text", x = rep(0, 6), y = c(0.0, 0.20, 0.40, 0.60, 0.80, 1.00), label = c("0.0","0.20", "0.40", "0.60", "0.80", "1.00") , color="black", size=3 , angle=0, fontface="bold", hjust=0) +
      
      geom_bar(aes(x=as.factor(id), y=value, fill=group), stat="identity", alpha=0.5) +
      ylim(-1.0, 1.2) +
      theme_minimal() +
      theme(
        legend.position = "none",
        axis.text = element_blank(),
        axis.title = element_blank(),
        panel.grid = element_blank(),
        plot.margin = unit(rep(-1,4), "cm") 
      ) +
      coord_polar() + 
      geom_text(data=label_data, aes(x=id, y=value+0.10, label=individual, hjust=hjust), color="black", fontface="bold",alpha=0.6, size=4, angle= label_data$angle, inherit.aes = FALSE ) +
      
      
      # Add base line information
      geom_segment(data=base_data, aes(x = start, y = -0.1, xend = end, yend = -0.1), colour = "black", alpha=0.8, size=0.6 , inherit.aes = FALSE )  +
      geom_text(data=base_data, aes(x = title, y = -0.15, label=group), hjust=c(arr), colour = "black", alpha=1, size=4, fontface="bold", inherit.aes = FALSE)
  })  
  
  
  # TAXATION
  output$political_dom_tax <- renderPlot({
    data <- read_csv("data/pol_final_2.csv") 
    data <- data %>% filter(dom=="Taxation")
    
    # Set a number of 'empty bar' to add at the end of each group
    empty_bar <- 3
    to_add <- data.frame( matrix(NA, empty_bar*nlevels(data$group), ncol(data)) )
    colnames(to_add) <- colnames(data)
    to_add$group <- rep(levels(data$group), each=empty_bar)
    data <- rbind(data, to_add)
    data <- data %>% arrange(group)
    data$id <- seq(1, nrow(data))
    
    # Get the name and the y position of each label
    label_data <- data
    number_of_bar <- nrow(label_data)
    angle <- 90 - 360 * (label_data$id-0.5) /number_of_bar     # I substract 0.5 because the letter must have the angle of the center of the bars. Not extreme right(1) or extreme left (0)
    label_data$hjust <- ifelse( angle < -90, 1, 0)
    label_data$angle <- ifelse(angle < -90, angle+180, angle)
    
    # prepare a data frame for base lines
    base_data <- data %>% 
      group_by(group) %>% 
      summarize(start=min(id), end=max(id) ) %>% 
      rowwise() %>% 
      mutate(title=mean(c(start, end)))
    
    # prepare a data frame for grid (scales)
    grid_data <- base_data
    grid_data$end <- grid_data$end[ c( nrow(grid_data), 1:nrow(grid_data)-1)] + 1
    grid_data$start <- grid_data$start - 1
    grid_data <- grid_data[-1,]
    
    ##conditional for format of justification of name
    if (length(unique(data$group))==4) {
      arr<- c(1,1,0,0)
    } else if (length(unique(data$group))==3) {
      arr<-c(1,0.3,0)
    } else if (length(unique(data$group))==2) {
      arr<-c(1,0)
    }
    
    # Make the plot
    ggplot(data, aes(x=as.factor(id), y=value, fill=group), width=200, height = 200) +       # Note that id is a factor. If x is numeric, there is some space between the first bar
      
      #add grid lines
      geom_hline(yintercept=0, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.20, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.40, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.60, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.80, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=1, color = "gray", size=0.2, alpha=1)+
      
      geom_bar(aes(x=as.factor(id), y=value, fill=group), stat="identity", alpha=0.5) +
      scale_fill_manual(values=c("#9FBE7A","#60999A","#31596E","#F9F1CB")) +
      
      # Add text showing the value of each 100/75/50/25 lines
      annotate("text", x = rep(0, 6), y = c(0.0, 0.20, 0.40, 0.60, 0.80, 1.00), label = c("0.0","0.20", "0.40", "0.60", "0.80", "1.00") , color="black", size=3 , angle=0, fontface="bold", hjust=0) +
      
      geom_bar(aes(x=as.factor(id), y=value, fill=group), stat="identity", alpha=0.5) +
      ylim(-1.0, 1.2) +
      theme_minimal() +
      theme(
        legend.position = "none",
        axis.text = element_blank(),
        axis.title = element_blank(),
        panel.grid = element_blank(),
        plot.margin = unit(rep(-1,4), "cm") 
      ) +
      coord_polar() + 
      geom_text(data=label_data, aes(x=id, y=value+0.10, label=individual, hjust=hjust), color="black", fontface="bold",alpha=0.6, size=4, angle= label_data$angle, inherit.aes = FALSE ) +
      
      
      # Add base line information
      geom_segment(data=base_data, aes(x = start, y = -0.1, xend = end, yend = -0.1), colour = "black", alpha=0.8, size=0.6 , inherit.aes = FALSE )  +
      geom_text(data=base_data, aes(x = title, y = -0.2, label=group), hjust=c(arr), colour = "black", alpha=1, size=4, fontface="bold", inherit.aes = FALSE)
    
  })  
  
  # HOUSING
  output$political_dom_hou <- renderPlot({
    data <- read_csv("data/pol_final_2.csv") 
    data <- data %>% filter(dom=="Housing")
    
    # Set a number of 'empty bar' to add at the end of each group
    empty_bar <- 3
    to_add <- data.frame( matrix(NA, empty_bar*nlevels(data$group), ncol(data)) )
    colnames(to_add) <- colnames(data)
    to_add$group <- rep(levels(data$group), each=empty_bar)
    data <- rbind(data, to_add)
    data <- data %>% arrange(group)
    data$id <- seq(1, nrow(data))
    
    # Get the name and the y position of each label
    label_data <- data
    number_of_bar <- nrow(label_data)
    angle <- 90 - 360 * (label_data$id-0.5) /number_of_bar     # I substract 0.5 because the letter must have the angle of the center of the bars. Not extreme right(1) or extreme left (0)
    label_data$hjust <- ifelse( angle < -90, 1, 0)
    label_data$angle <- ifelse(angle < -90, angle+180, angle)
    
    # prepare a data frame for base lines
    base_data <- data %>% 
      group_by(group) %>% 
      summarize(start=min(id), end=max(id) ) %>% 
      rowwise() %>% 
      mutate(title=mean(c(start, end)))
    
    # prepare a data frame for grid (scales)
    grid_data <- base_data
    grid_data$end <- grid_data$end[ c( nrow(grid_data), 1:nrow(grid_data)-1)] + 1
    grid_data$start <- grid_data$start - 1
    grid_data <- grid_data[-1,]
    
    ##conditional for format of justification of name
    if (length(unique(data$group))==4) {
      arr<- c(1,1,0,0)
    } else if (length(unique(data$group))==3) {
      arr<-c(1,0.3,0)
    } else if (length(unique(data$group))==2) {
      arr<-c(1,0)
    }
    
    # Make the plot
    ggplot(data, aes(x=as.factor(id), y=value, fill=group), width=800, height = 800) +       # Note that id is a factor. If x is numeric, there is some space between the first bar
      
      #add grid lines
      geom_hline(yintercept=0, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.20, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.40, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.60, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.80, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=1, color = "gray", size=0.2, alpha=1)+
      
      geom_bar(aes(x=as.factor(id), y=value, fill=group), stat="identity", alpha=0.5) +
      scale_fill_manual(values=c("#9FBE7A","#60999A","#31596E","#F9F1CB")) +
      
      # Add text showing the value of each 100/75/50/25 lines
      annotate("text", x = rep(0, 6), y = c(0.0, 0.20, 0.40, 0.60, 0.80, 1.00), label = c("0.0","0.20", "0.40", "0.60", "0.80", "1.00") , color="black", size=3 , angle=0, fontface="bold", hjust=0) +
      
      geom_bar(aes(x=as.factor(id), y=value, fill=group), stat="identity", alpha=0.5) +
      ylim(-1.0, 1.2) +
      theme_minimal() +
      theme(
        legend.position = "none",
        axis.text = element_blank(),
        axis.title = element_blank(),
        panel.grid = element_blank(),
        plot.margin = unit(rep(-1,4), "cm") 
      ) +
      coord_polar() + 
      geom_text(data=label_data, aes(x=id, y=value+0.10, label=individual, hjust=hjust), color="black", fontface="bold",alpha=0.6, size=4, angle= label_data$angle, inherit.aes = FALSE ) +
      
      
      # Add base line information
      geom_segment(data=base_data, aes(x = start, y = -0.1, xend = end, yend = -0.1), colour = "black", alpha=0.8, size=0.6 , inherit.aes = FALSE )  +
      geom_text(data=base_data, aes(x = title, y = -0.2, label=group), hjust=c(arr), colour = "black", alpha=1, size=4, fontface="bold", inherit.aes = FALSE)
    
  })  
  
  # EMPLOYMENT
  output$political_dom_emp <- renderPlot({
    data <- read_csv("data/pol_final_2.csv") 
    data <- data %>% filter(dom=="Employment")
    
    # Set a number of 'empty bar' to add at the end of each group
    empty_bar <- 3
    to_add <- data.frame( matrix(NA, empty_bar*nlevels(data$group), ncol(data)) )
    colnames(to_add) <- colnames(data)
    to_add$group <- rep(levels(data$group), each=empty_bar)
    data <- rbind(data, to_add)
    data <- data %>% arrange(group)
    data$id <- seq(1, nrow(data))
    
    # Get the name and the y position of each label
    label_data <- data
    number_of_bar <- nrow(label_data)
    angle <- 90 - 360 * (label_data$id-0.5) /number_of_bar     # I substract 0.5 because the letter must have the angle of the center of the bars. Not extreme right(1) or extreme left (0)
    label_data$hjust <- ifelse( angle < -90, 1, 0)
    label_data$angle <- ifelse(angle < -90, angle+180, angle)
    
    # prepare a data frame for base lines
    base_data <- data %>% 
      group_by(group) %>% 
      summarize(start=min(id), end=max(id) ) %>% 
      rowwise() %>% 
      mutate(title=mean(c(start, end)))
    
    # prepare a data frame for grid (scales)
    grid_data <- base_data
    grid_data$end <- grid_data$end[ c( nrow(grid_data), 1:nrow(grid_data)-1)] + 1
    grid_data$start <- grid_data$start - 1
    grid_data <- grid_data[-1,]
    
    ##conditional for format of justification of name
    if (length(unique(data$group))==4) {
      arr<- c(1,1,0,0)
    } else if (length(unique(data$group))==3) {
      arr<-c(1,0.3,0)
    } else if (length(unique(data$group))==2) {
      arr<-c(1,0)
    }
    
    # Make the plot
    ggplot(data, aes(x=as.factor(id), y=value, fill=group), width=800, height = 800) +       # Note that id is a factor. If x is numeric, there is some space between the first bar
      
      #add grid lines
      geom_hline(yintercept=0, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.20, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.40, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.60, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.80, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=1, color = "gray", size=0.2, alpha=1)+
      
      geom_bar(aes(x=as.factor(id), y=value, fill=group), stat="identity", alpha=0.5) +
      scale_fill_manual(values=c("#9FBE7A","#60999A","#31596E","#F9F1CB")) +
      
      # Add text showing the value of each 100/75/50/25 lines
      annotate("text", x = rep(0, 6), y = c(0.0, 0.20, 0.40, 0.60, 0.80, 1.00), label = c("0.0","0.20", "0.40", "0.60", "0.80", "1.00") , color="black", size=3 , angle=0, fontface="bold", hjust=0) +
      
      geom_bar(aes(x=as.factor(id), y=value, fill=group), stat="identity", alpha=0.5) +
      ylim(-1.0, 1.2) +
      theme_minimal() +
      theme(
        legend.position = "none",
        axis.text = element_blank(),
        axis.title = element_blank(),
        panel.grid = element_blank(),
        plot.margin = unit(rep(-1,4), "cm") 
      ) +
      coord_polar() + 
      geom_text(data=label_data, aes(x=id, y=value+0.10, label=individual, hjust=hjust), color="black", fontface="bold",alpha=0.6, size=4, angle= label_data$angle, inherit.aes = FALSE ) +
      
      
      # Add base line information
      geom_segment(data=base_data, aes(x = start, y = -0.1, xend = end, yend = -0.1), colour = "black", alpha=0.8, size=0.6 , inherit.aes = FALSE )  +
      geom_text(data=base_data, aes(x = title, y = -0.2, label=group), hjust=c(arr), colour = "black", alpha=1, size=4, fontface="bold", inherit.aes = FALSE)
  })  
  
  
  # VOTING
  output$political_dom_vot <- renderPlot({
    data <- read_csv("data/pol_final_2.csv") 
    data <- data %>% filter(dom=="Voting")
    
    # Set a number of 'empty bar' to add at the end of each group
    empty_bar <- 3
    to_add <- data.frame( matrix(NA, empty_bar*nlevels(data$group), ncol(data)) )
    colnames(to_add) <- colnames(data)
    to_add$group <- rep(levels(data$group), each=empty_bar)
    data <- rbind(data, to_add)
    data <- data %>% arrange(group)
    data$id <- seq(1, nrow(data))
    
    # Get the name and the y position of each label
    label_data <- data
    number_of_bar <- nrow(label_data)
    angle <- 90 - 360 * (label_data$id-0.5) /number_of_bar     # I substract 0.5 because the letter must have the angle of the center of the bars. Not extreme right(1) or extreme left (0)
    label_data$hjust <- ifelse( angle < -90, 1, 0)
    label_data$angle <- ifelse(angle < -90, angle+180, angle)
    
    # prepare a data frame for base lines
    base_data <- data %>% 
      group_by(group) %>% 
      summarize(start=min(id), end=max(id) ) %>% 
      rowwise() %>% 
      mutate(title=mean(c(start, end)))
    
    # prepare a data frame for grid (scales)
    grid_data <- base_data
    grid_data$end <- grid_data$end[ c( nrow(grid_data), 1:nrow(grid_data)-1)] + 1
    grid_data$start <- grid_data$start - 1
    grid_data <- grid_data[-1,]
    
    ##conditional for format of justification of name
    if (length(unique(data$group))==4) {
      arr<- c(1,1,0,0)
    } else if (length(unique(data$group))==3) {
      arr<-c(1,0.3,0)
    } else if (length(unique(data$group))==2) {
      arr<-c(1,0)
    }
    
    # Make the plot
    ggplot(data, aes(x=as.factor(id), y=value, fill=group), width=800, height = 800) +       # Note that id is a factor. If x is numeric, there is some space between the first bar
      
      #add grid lines
      geom_hline(yintercept=0, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.20, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.40, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.60, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=0.80, color = "gray", size=0.2, alpha=1)+
      geom_hline(yintercept=1, color = "gray", size=0.2, alpha=1)+
      
      geom_bar(aes(x=as.factor(id), y=value, fill=group), stat="identity", alpha=0.5) +
      scale_fill_manual(values=c("#9FBE7A","#60999A","#31596E","#F9F1CB")) +
      
      # Add text showing the value of each 100/75/50/25 lines
      annotate("text", x = rep(0, 6), y = c(0.0, 0.20, 0.40, 0.60, 0.80, 1.00), label = c("0.0","0.20", "0.40", "0.60", "0.80", "1.00") , color="black", size=3 , angle=0, fontface="bold", hjust=0) +
      
      geom_bar(aes(x=as.factor(id), y=value, fill=group), stat="identity", alpha=0.5) +
      ylim(-1.0, 1.2) +
      theme_minimal() +
      theme(
        legend.position = "none",
        axis.text = element_blank(),
        axis.title = element_blank(),
        panel.grid = element_blank(),
        plot.margin = unit(rep(-1,4), "cm") 
      ) +
      coord_polar() + 
      geom_text(data=label_data, aes(x=id, y=value+0.10, label=individual, hjust=hjust), color="black", fontface="bold",alpha=0.6, size=4, angle= label_data$angle, inherit.aes = FALSE ) +
      
      # Add base line information
      geom_segment(data=base_data, aes(x = start, y = -0.1, xend = end, yend = -0.1), colour = "black", alpha=0.8, size=0.6 , inherit.aes = FALSE )  +
      geom_text(data=base_data, aes(x = title, y = -0.2, label=group), hjust=c(arr), colour = "black", alpha=1, size=4, fontface="bold", inherit.aes = FALSE)
    
  })
  
  #
  # Cultural - Religion - Boxplot and Map------------------
  # 
  
  # continuous indicator function
  create_continuous_indicator <- function(data, myvar, myvarlabel){
    pal <- colorNumeric(cbGreens[1:5], domain = myvar)
    
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
                title = myvarlabel,
                opacity = 0.7,
                na.label = "Not Available"#,
                #labFormat = function(type, cuts, p) {
                #  n = length(cuts)
                #  paste0("[", round(cuts[-n], 2), " &ndash; ", round(cuts[-1], 2), ")")
                #}
      )
  }
  
  
  
  output$plot_cult_index_rich <- renderLeaflet({
    
    data_var <- cult_data()$cult_rich
    var_label <- "Number of Religious Groups"
    
    create_continuous_indicator(cult_data(), data_var, var_label)
  })
  
  
  output$plot_cult_index_gsi <- renderLeaflet({
    
    data_var <- cult_data()$cult_gsi
    var_label <- "Gini-Simpson Index of Diversity"
    
    create_continuous_indicator(cult_data(), data_var, var_label)
  }) 
  
  output$plotly_cult_index_rich <- renderPlotly({
    
    data_var <- cult_data()$cult_rich
    var_label <- "Number of Religious Groups"
    
    create_boxplot(cult_data(), data_var, var_label)
  })
  
  
  output$plotly_cult_index_gsi <- renderPlotly({
    
    data_var <- cult_data()$cult_gsi
    var_label <- "Gini-Simpson Index of Diversity"
    
    create_boxplot(cult_data(), data_var, var_label)
  })
  
  ##
  
  output$plot_cult_index_ancrich <- renderLeaflet({
    
    data_var <- cult_data()$anc_rich
    var_label <- "Number of Ancestry Groups"
    
    create_continuous_indicator(cult_data(), data_var, var_label)
  })
  
  
  output$plot_cult_index_ancgsi <- renderLeaflet({
    
    data_var <- cult_data()$anc_gsi
    var_label <- "Gini-Simpson Index of Diversity"
    
    create_continuous_indicator(cult_data(), data_var, var_label)
  }) 
  
  output$plotly_cult_index_ancrich <- renderPlotly({
    
    data_var <- cult_data()$anc_rich
    var_label <- "Number of Ancestry Groups"
    
    create_boxplot(cult_data(), data_var, var_label)
  })
  
  
  output$plotly_cult_index_ancgsi <- renderPlotly({
    
    data_var <- cult_data()$anc_gsi
    var_label <- "Gini-Simpson Index of Diversity"
    
    create_boxplot(cult_data(), data_var, var_label)
  })
  
  
  # 
  # Built - Housing Outcomes - Boxplot and Map ------------------
  #  
  
  # index
  output$plotly_built_index_housing <- renderPlotly({
    
    data_var <- built_data()$built_housing_index
    var_label <- "Built Housing Index"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_index_housing <- renderLeaflet({
    
    data_var <- built_data()$built_housing_index
    var_label <- "Built Housing Index"
    
    create_indicator_bins(built_data(), data_var, var_label)
  })
  
  output$plotly_built_housing_singlefam <- renderPlotly({
    
    data_var <- built_data()$built_pctsinghaus
    var_label <- "Percentage of Households in Detached Single Family Units"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_housing_singlefam <- renderLeaflet({
    
    data_var <- built_data()$built_pctsinghaus
    var_label <- "Percentage of Households in Detached Single Family Units"
    
    create_indicator(built_data(), data_var, var_label)
  }) 
  
  output$plotly_built_housing_plumbing <- renderPlotly({
    
    data_var <- built_data()$prc_complete_plumbing
    var_label <- "Percentage of Households with Complete Plumbing"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_housing_plumbing <- renderLeaflet({
    
    data_var <- built_data()$prc_complete_plumbing
    var_label <- "Percentage of Households with Complete Plumbing"
    
    create_indicator(built_data(), data_var, var_label)
  }) 
  
  output$plotly_built_housing_nonvacant <- renderPlotly({
    
    data_var <- built_data()$built_pctnonvacant
    var_label <- "Percentage of Non-Vacant Properties"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_housing_nonvacant <- renderLeaflet({
    
    data_var <- built_data()$built_pctnonvacant
    var_label <- "Percentage of Non-Vacant Properties"
    
    create_indicator(built_data(), data_var, var_label)
  }) 
  
  output$plotly_built_housing_medpropage <- renderPlotly({
    
    data_var <- built_data()$built_medyrbuilt
    var_label <- "Median Year of Built Structures"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_housing_medpropage <- renderLeaflet({
    
    data_var <- built_data()$built_medyrbuilt
    var_label <- "Median Year of Built Structures"
    
    create_indicator(built_data(), data_var, var_label)
  }) 
  
  output$plotly_built_housing_medpropval <- renderPlotly({
    
    data_var <- built_data()$built_medpropval
    var_label <- "Median Household Property Value"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_housing_medpropval <- renderLeaflet({
    
    data_var <- built_data()$built_medpropval
    var_label <- "Median Household Property Value"
    
    create_indicator(built_data(), data_var, var_label)
  }) 
  
  # 
  # Built - Telecommunications Outcomes - Boxplot and Map ------------------
  # 
  
  
  # index
  output$plotly_built_index_telecom <- renderPlotly({
    
    data_var <- built_data()$built_telecom_index
    var_label <- "Built Telecommunications Index"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_index_telecom <- renderLeaflet({
    
    data_var <- built_data()$built_telecom_index
    var_label <- "Built Telecommunications Index"
    
    create_indicator(built_data(), data_var, var_label)
  })
  
 
  output$plotly_built_telecom_compuse <- renderPlotly({
    
    data_var <- built_data()$built_lib_computeruse_adj
    var_label <- "Uses of Public Internet Computers in Libaries per 100,000 Population"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_telecom_compuse <- renderLeaflet({
    
    data_var <- built_data()$built_lib_computeruse_adj
    var_label <- "Uses of Public Internet Computers in Libaries per 100,000 Population"
    
    create_indicator_bins(built_data(), data_var, var_label)
  })
  
  output$plotly_built_telecom_libcomps <- renderPlotly({
    
    data_var <- built_data()$built_lib_avcomputers_adj
    var_label <- "Number of Computers in Public Libraries per 100,000 Population"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_telecom_libcomps <- renderLeaflet({
    
    data_var <- built_data()$built_lib_avcomputers_adj
    var_label <- "Number of Computers in Public Libraries per 100,000 Population"
    
    create_indicator_bins(built_data(), data_var, var_label)
  }) 
  
  output$plotly_built_telecom_libs <- renderPlotly({
    
    data_var <- built_data()$built_publibs_adj
    var_label <- "Number of Public Libraries Per 100,000 Population"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_telecom_libs <- renderLeaflet({
    
    data_var <- built_data()$built_publibs_adj
    var_label <- "Number of Public Libraries Per 100,000 Population"
    
    create_indicator_bins(built_data(), data_var, var_label)
  }) 
  
  output$plotly_built_telecom_towers <- renderPlotly({
    
    data_var <- built_data()$built_cell_tower_adj
    var_label <- "Number of Cell Towers Per Acre"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_telecom_towers <- renderLeaflet({
    
    data_var <- built_data()$built_cell_tower_adj
    var_label <- "Number of Cell Towers Per Acre"
    
    create_indicator(built_data(), data_var, var_label)
  }) 
  
  output$plotly_built_telecom_hholdbband <- renderPlotly({
    
    data_var <- built_data()$built_pctbband
    var_label <- "Percentage of Households with Broadband Subscription"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_telecom_hholdbband <- renderLeaflet({
    
    data_var <- built_data()$built_pctbband
    var_label <- "Percentage of Households with Broadband Subscription"
    
    create_indicator(built_data(), data_var, var_label)
  }) 
  
  
  output$plotly_built_telecom_2bbandpvdrs <- renderPlotly({
    
    data_var <- built_data()$built_pct2bbandprov
    var_label <- "Percentage of Households with Two Broadband Providers"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_telecom_2bbandpvdrs <- renderLeaflet({
    
    data_var <- built_data()$built_pct2bbandprov
    var_label <- "Percentage of Households with Two Broadband Providers"
    
    create_indicator(built_data(), data_var, var_label)
  }) 
  
  
  # 
  # Built - Transportation Facilities - Boxplot and Map ------------------
  #  
  
  # index
  output$plotly_built_index_transpo <- renderPlotly({
    
    data_var <- built_data()$built_transpo_index
    var_label <- "Built Transportation Index"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_index_transpo <- renderLeaflet({
    
    data_var <- built_data()$built_transpo_index
    var_label <- "Built Transportation Index"
    
    create_indicator(built_data(), data_var, var_label)
  })
  
  output$plotly_built_miles <- renderPlotly({
    
    data_var <- built_data()$built_miles_of_road_adj
    var_label <- "Miles of Roads per Acre"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_miles <- renderLeaflet({
    
    data_var <- built_data()$built_miles_of_road_adj
    var_label <- "Miles of Roads per Acre"
    
    create_indicator(built_data(), data_var, var_label)
  })
  
  output$plotly_built_roads <- renderPlotly({
    
    data_var <- built_data()$built_road_count_adj
    var_label <- "Total Roads per Acre"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_roads <- renderLeaflet({
    
    data_var <- built_data()$built_road_count_adj
    var_label <- "Total Roads per Acre"
    
    create_indicator(built_data(), data_var, var_label)
  })
  
  output$plotly_built_bridgequality <- renderPlotly({
    
    data_var <- built_data()$built_perc_poor_bridges
    var_label <- "Percentage of Low Quality Bridges"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_bridgequality <- renderLeaflet({
    
    data_var <- built_data()$built_perc_poor_bridges
    var_label <- "Percentage of Low Quality Bridges"
    
    create_indicator(built_data(), data_var, var_label)
  }) 
  
  output$plotly_built_bridges <- renderPlotly({
    
    data_var <- built_data()$built_bridge_count_adj
    var_label <- "Number of Bridges per Acre"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_bridges <- renderLeaflet({
    
    data_var <- built_data()$built_bridge_count_adj
    var_label <- "Number of Bridges per Acre"
    
    create_indicator(built_data(), data_var, var_label)
  }) 
  
  # 
  # Built - Educational Facilities - Boxplot and Map ------------------
  #  

  # index
  output$plotly_built_index_edu <- renderPlotly({
    
    data_var <- built_data()$built_edu_index
    var_label <- "Built Educational Facilities Index"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_index_edu <- renderLeaflet({
    
    data_var <- built_data()$built_edu_index
    var_label <- "Built Educational Facilities Index"
    
    create_indicator_bins(built_data(), data_var, var_label)
  })
  
  output$plotly_built_suppcolleges <- renderPlotly({
    
    data_var <- built_data()$built_suppcollege_adj
    var_label <- "Supplementary Colleges per 100,000 Population"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_suppcolleges <- renderLeaflet({
    
    data_var <- built_data()$built_suppcollege_adj
    var_label <- "Supplementary Colleges per 100,000 Population"
    
    create_indicator_bins(built_data(), data_var, var_label)
  }) 
  
  output$plotly_built_universities <- renderPlotly({
    
    data_var <- built_data()$built_university_adj
    var_label <- "Universities per 100,000 Population"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_universities <- renderLeaflet({
    
    data_var <- built_data()$built_university_adj_q
    var_label <- "Universities per 100,000 Population"
    
    create_indicator_bins(built_data(), data_var, var_label)
  }) 
  
  output$plotly_built_private_schools <- renderPlotly({
    
    data_var <- built_data()$built_privateschool_adj
    var_label <- "Private Schools per 100,000 Population"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_private_schools <- renderLeaflet({
    
    data_var <- built_data()$built_privateschool_adj
    var_label <- "Private Schools per 100,000 Population"
    
    create_indicator_bins(built_data(), data_var, var_label)
  }) 
  
  output$plotly_built_public_schools <- renderPlotly({
    
    data_var <- built_data()$built_publicschool_adj
    var_label <- "Public Schools per 100,000 Population"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_public_schools <- renderLeaflet({
    
    data_var <- built_data()$built_publicschool_adj
    var_label <- "Public Schools per 100,000 Population"
    
    create_indicator(built_data(), data_var, var_label)
  })
  
  
  # 
  # Built - Emergency Facilities - Boxplot and Map ------------------
  #  
  
  # index
  output$plotly_built_index_emerg <- renderPlotly({
    
    data_var <- built_data()$built_emerg_index
    var_label <- "Built Emergency Facilities Index"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_index_emerg <- renderLeaflet({
    
    data_var <- built_data()$built_emerg_index
    var_label <- "Built Emergency Facilities Index"
    
    create_indicator(built_data(), data_var, var_label)
  })

  output$plotly_built_police <- renderPlotly({
    
    data_var <- built_data()$built_localpolice_adj
    var_label <- "Police Stations per 100,000 Population"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_police <- renderLeaflet({
    
    data_var <- built_data()$built_localpolice_adj
    var_label <- "Police Stations per 100,000 Population"
    
    create_indicator(built_data(), data_var, var_label)
  })
  
  output$plotly_built_fire <- renderPlotly({
    
    data_var <- built_data()$built_fire_stations_adj
    var_label <- "Fire Stations per 100,000 Population"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_fire <- renderLeaflet({
    
    data_var <- built_data()$built_fire_stations_adj
    var_label <- "Fire Stations per 100,000 Population"
    
    create_indicator(built_data(), data_var, var_label)
  })
  
  output$plotly_built_mentalhealth <- renderPlotly({
    
    data_var <- built_data()$built_mentalhealthfacs_adj
    var_label <- "Mental Health Facilities per 100,000 Population"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_mentalhealth <- renderLeaflet({
    
    data_var <- built_data()$built_mentalhealthfacs_adj
    var_label <- "Mental Health Facilities per 100,000 Population"
    
    create_indicator(built_data(), data_var, var_label)
  })
  
  output$plotly_built_urgentcare <- renderPlotly({
    
    data_var <- built_data()$built_urgentcares_adj
    var_label <- "Urgent Care Facilities per 100,000 Population"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_urgentcare <- renderLeaflet({
    
    data_var <- built_data()$built_urgentcares_adj
    var_label <- "Urgent Care Facilities per 100,000 Population"
    
    create_indicator_bins(built_data(), data_var, var_label)
  })
  
  output$plotly_built_hospitals <- renderPlotly({
    
    data_var <- built_data()$built_hospitals_adj
    var_label <- "Hospitals per 100,000 Population"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_hospitals <- renderLeaflet({
    
    data_var <- built_data()$built_hospitals_adj
    var_label <- "Hospitals per 100,000 Population"
    
    create_indicator(built_data(), data_var, var_label)
  })
  
  # 
  # Built - Convention Facilities - Boxplot and Map ------------------
  #  
  
  # index
  output$plotly_built_index_conv <- renderPlotly({
    
    data_var <- built_data()$built_conv_index
    var_label <- "Convention Facilities Index"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_index_conv <- renderLeaflet({
    
    data_var <- built_data()$built_conv_index
    var_label <- "Convention Facilities Index"
    
    create_indicator(built_data(), data_var, var_label)
  })
  
  output$plotly_built_sports <- renderPlotly({
    
    data_var <- built_data()$built_sportvenues_adj
    var_label <- "Sports Venues per 100,000 Population"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_sports <- renderLeaflet({
    
    data_var <- built_data()$built_sportvenues_adj
    var_label <- "Sports Venues per 100,000 Population"
    
    create_indicator_bins(built_data(), data_var, var_label)
  })
  
  output$plotly_built_fairgrounds <- renderPlotly({
    
    data_var <- built_data()$built_fairgrounds_adj
    var_label <- "Fairgrounds/Convention Centers per 100,000 Population"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_fairgrounds <- renderLeaflet({
    
    data_var <- built_data()$built_fairgrounds_adj
    var_label <- "Fairgrounds/Convention Centers per 100,000 Population"
    
    create_indicator(built_data(), data_var, var_label)
  })
  
  output$plotly_built_worship <- renderPlotly({
    
    data_var <- built_data()$built_placesofworship_adj
    var_label <- "Places of Worship per 100,000 Population"
    
    create_boxplot(built_data(), data_var, var_label)
  })
  
  output$plot_built_worship <- renderLeaflet({
    
    data_var <- built_data()$built_placesofworship_adj
    var_label <- "Places of Worship per 100,000 Population"
    
    create_indicator(built_data(), data_var, var_label)
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
  
  #--------- Bibliography table -------------------------
  #
  biblio_topic <- reactive({
    input$topic_biblio
  })
  
  output$biblio_table <- renderDataTable({
    if(biblio_topic() == "All"){
      table <- as.data.frame(biblio)
      names(table) <- c("Author", "Title", "Journal", "Volume", "Number", "Pages", "Year", "Capital", "Index")
      datatable(table, rownames = FALSE, options = list(pageLength = 15)) 
    }
    else{
      data <- switch(input$topic_biblio,
                     "Financial" = "Financial",
                     "Human" = "Human",
                     "Social" = "Social",
                     "Natural" = "Natural", 
                     "Built" = "Built",
                     "Political" = "Political", 
                     "Cultural" = "Cultural")
      
      table <- biblio[biblio$Capital == data, ]
      table <- as.data.frame(table)
      datatable(table, rownames = FALSE, options = list(pageLength = 15)) 
    }
  })
  
  
  #
  # Home Page InfoBox outputs -------------------------------------------------
  # 
  
  output$fin_ibox <- renderInfoBox({
    ic <- apputils::icon(list(src = "icons/Financial.Dollar.Bill.jpg", width = "80px"), lib = "local")
    
    apputils::infoBox(title = a("Financial Capital", onclick = "openTab('financial')", href="#"), 
                      color = "olive",
                      validate.color = F,
                      icon = ic, 
                      value = tags$h5("Financial capital refers to the economic features of the community such as debt capital, investment capital,
                                      savings, tax revenue, tax abatements, and grants, as well as entrepreneurship, persistent poverty, 
                                      industry concentration, and philanthropy.") 
                      )
  })
  
  output$hum_ibox <- renderInfoBox({
    ic <- apputils::icon(list(src = "icons/Human.Person.jpg", width = "60px"), lib = "local")
    
    apputils::infoBox(title = a("Human Capital", onclick = "openTab('human')", href="#"),
                      color = "olive", icon = ic, 
                      value = tags$h5("Human capital refers to the knowledge, skills, education, credentials, physical health, mental health, 
                                      and other acquired or inherited traits essential for an optimal quality of life.")
                      )
  })
  
  output$soc_ibox <- renderInfoBox({
    ic <- apputils::icon(list(src = "icons/Social.Tripod.jpg", width = "80px"), lib = "local")
    
    apputils::infoBox(title = a("Social Capital", onclick = "openTab('social')", href="#"),
                      color = "olive", icon = ic, 
                      value = tags$h5("Social capital refers to the resources, information, and support that communities can access 
                                      through the bonds among members of the community and their families  that promote mutual trust, 
                                      reciprocity, collective identity, and a sense of a shared future.")
                      )
  })
  
  output$built_ibox <- renderInfoBox({
    ic <- apputils::icon(list(src = "icons/Built.Bricks.jpg", width = "80px"), lib = "local")
    
    apputils::infoBox(title = a("Built Capital", onclick = "openTab('built')", href="#"),
                      color = "olive", icon = ic, 
                      value = tags$h5("Built capital refers to the physical infrastructure that facilitates community activities, 
                                      such as broadband and other information technologies, utilities, water/sewer systems, roads 
                                      and bridges, business parks, hospitals, main street buildings, playgrounds, and housing.")
                      )
  })
  
  output$nat_ibox <- renderInfoBox({
    ic <- apputils::icon(list(src = "icons/Natural.Tree.jpg", width = "55px"), lib = "local")
    
    apputils::infoBox(title = a("Natural Capital", onclick = "openTab('natural')", href="#"),
                      color = "olive", icon = ic, 
                      value = tags$h5("Natural capital refers to the stock of natural or environmental ecosystem assets that provide a 
                                      flow of useful goods or services to create possibilities and limits to community development, 
                                      such as air, water, soil, biodiversity, and weather.")
    )
  })
  
  output$pol_ibox <- renderInfoBox({
    ic <- apputils::icon(list(src = "icons/Political.Govt.Bldg.jpg", width = "70px"), lib = "local")
    
    apputils::infoBox(title = a("Political Capital", onclick = "openTab('political')", href="#"),
                      color = "olive", icon = ic,
                      value = tags$h5("Political capital refers to the ability of a community to influence and enforce rules, regulations, 
                                      and standards through their organizations, connections, voice, and power as citizens.")
    )
  })
  
  output$cult_ibox <- renderInfoBox({
    ic <- apputils::icon(list(src = "icons/Cultural.Drama.Mask.jpg", width = "80px"), lib = "local")
    
    apputils::infoBox(title = a("Cultural Capital", onclick = "openTab('cultural')", href="#"),
                      color = "olive", icon = ic, 
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