# Function for indicator boxplots --------------------------
library(plotly)
library(readr)
library(RColorBrewer)
library(dplyr)
cbGreens2 <- c("#F9F1CB", "#D9BCA3", "#CCA98B", "#BCBBBC", "#9FBE7A", "#8B8F5C", "#7F842C")
datahum <- read_rds("./rivanna_data/human/hum_final.Rds") 
# Function for indicator boxplots --------------------------
create_boxplot <- function(data, myvar, myvarlabel) {
  
  group = as.factor(data$state)
  
  data %>%
    plot_ly(colors = cbGreens2) %>%   # this is the only change!
    add_trace(x = as.numeric(group),
              y = ~myvar,
              showlegend = F,
              hoverinfo = "y",
              type = "box",
              marker = list(symbol = "asterisk-open"),
              name = "") %>%
    add_markers(x = ~jitter(as.numeric(group), amount = 0.1), y = ~myvar, color = ~irr2010_discretize,
                marker = list(size = 6),
                hoverinfo = "text",
                text = ~paste0("Rurality Index: ", round(irr2010,2),
                               "<br>County: ",county),
                showlegend = TRUE) %>%
    layout(title = "",
           xaxis = list(title = myvarlabel,
                        zeroline = FALSE,
                        showticklabels = FALSE),
           yaxis = list(title = "",
                        zeroline = FALSE,
                        hoverformat = ".2f"))
}
create_boxplot(datahum, datahum$hum_pcths, "Percent HS")

