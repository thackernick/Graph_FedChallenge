rm(list = ls())
####preliminaries####
library(readxl)        # To read Excel files if needed
library(tidyr)         # For data reshaping (wide to long format, etc.)
library(ggplot2)       # For data visualization
library(dplyr)         # For data manipulation (filtering, selecting, etc.)
library(tidyverse)     # A meta-package that includes ggplot2, dplyr, and others
library(fredr)         # For accessing Federal Reserve Economic Data (FRED)
library(ggThemeAssist) # For helping with theme adjustments in ggplot2
library(ggthemes)      # Provides extra themes for ggplot2
library(Cairo)         # To handle graphical devices like PNG exports
library(hrbrthemes)    # A collection of ggplot2 themes
library(lubridate)     # For working with dates
library(zoo)           # For time series manipulation

# Set the working directory based on the current RStudio document
setwd()

####Aesthetics####
font = "Times New Roman"   # Font used in the plot
font_size = 22             # Font size for labels
paint = c("#2c608a", "#b93936", "#89ae43", "#fbc632", "#89cce7")  # Custom color palette

# Set the start and end dates for the data range
start_date <- as.Date("2000-01-01")
end_date <- as.Date(Sys.Date())  # Current date as the end

# Set your FRED API key to access the data (replace with your own if needed)
fredr_set_key("Your key")

####Import Data from FRED####
sahm <- fredr(
  series_id = 'SAHMCURRENT',
  observation_start = start_date, 
  observation_end = end_date
)

# Convert the 'date' column to a Date type and keep only the relevant columns
sahm$date <- as.Date(sahm$date)
sahm <- sahm %>% select(date, value)



#### Recession Stuff #####

recessions = read.table(textConnection(
  "Peak, Trough
1857-06-01, 1858-12-01
1860-10-01, 1861-06-01
1865-04-01, 1867-12-01
1869-06-01, 1870-12-01
1873-10-01, 1879-03-01
1882-03-01, 1885-05-01
1887-03-01, 1888-04-01
1890-07-01, 1891-05-01
1893-01-01, 1894-06-01
1895-12-01, 1897-06-01
1899-06-01, 1900-12-01
1902-09-01, 1904-08-01
1907-05-01, 1908-06-01
1910-01-01, 1912-01-01
1913-01-01, 1914-12-01
1918-08-01, 1919-03-01
1920-01-01, 1921-07-01
1923-05-01, 1924-07-01
1926-10-01, 1927-11-01
1929-08-01, 1933-03-01
1937-05-01, 1938-06-01
1945-02-01, 1945-10-01
1948-11-01, 1949-10-01
1953-07-01, 1954-05-01
1957-08-01, 1958-04-01
1960-04-01, 1961-02-01
1969-12-01, 1970-11-01
1973-11-01, 1975-03-01
1980-01-01, 1980-07-01
1981-07-01, 1982-11-01
1990-07-01, 1991-03-01
2001-03-01, 2001-11-01
2007-12-01, 2009-06-01
2020-02-01, 2020-04-01"), 
  sep=',', colClasses=c('Date', 'Date'), header=TRUE)

# Filter recessions within the desired date range
recessions_filtered <- recessions %>%
  filter(Peak >= start_date & Trough <= end_date)

#### Plot ####
threshold_df <- data.frame(
  date = seq(min(sahm$date), max(sahm$date), by = "day"),
  value = 0.5
)

p1 <- ggplot(sahm) + 
  # Add shaded recession bars
  geom_rect(data = recessions_filtered, aes(xmin = Peak, xmax = Trough, ymin = -Inf, ymax = +Inf), 
            fill = 'grey', alpha = 0.5) +
  
  # Add the threshold line using geom_segment to specify exact limits
  # geom_segment(aes(x = min(sahm$date), xend = max(sahm$date), y = 0.5, yend = 0.5, color = 'Threshold: 0.50pp'), linetype = "dashed", size = 1) + 
  geom_line(aes(x=date, y =0.5, color = 'Threshold (0.50pp)'), size = 1,linetype='dashed') +
  
  # Plot Sahm rule data
  geom_line(aes(x = date, y = value, color = 'Sahm Rule Recession Indicator'), size = 1.5) +
  

  # Customize labels
  ylab('Percentage Points') +
  xlab('Source: Claudia Sahm | Shaded Area Indicates US Recession') + 
  
  # Adjust y-axis to cut off at 6 percentage points
  # scale_y_continuous(breaks = seq(-3, 8, 1.5), limits = c(-3, NA), expand = expansion(mult = c(0, 0.05)))+
  scale_y_continuous(breaks = seq(-2, 10, 2), limits = c(-2, 10)) + 
  scale_x_date(date_labels = '%Y') +
  
  # Set color scheme
  scale_color_manual(name = '', values = c('Sahm Rule Recession Indicator' = paint[1], 'Threshold (0.50pp)' = paint[2])) + 
  
  # Apply theme settings
  theme_ipsum() + 
  coord_cartesian(expand=F)+
  #coord_cartesian(clip = 'off', expand = FALSE) +  # Use clip = 'off'
  theme(
    axis.title.x = element_text(family = font, size = 14, color = 'gray40', hjust = 0.5, vjust = -3), 
    axis.line = element_line(size = 0.5),
    axis.title.y = element_text(family = font, size = font_size, color = 'black', hjust = 0.5, vjust = 5),
    axis.text.x = element_text(family = font, colour = "black", angle = 0, size = font_size, hjust = -0.1), 
    axis.text.y = element_text(family = font, color = 'black', size = font_size), 
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    plot.title = element_text(family = font, size = 42, color = 'black', hjust = 0.1, vjust=3), 
    legend.position = c(.6, .90), 
    legend.text = element_text(family = font, color = 'black', size = 18)
   # legend.background = element_rect(fill = NA, color = NA),  
    #plot.margin = margin(t = 30, r = 80, b = 30, l = 60)
  )

# Plot the graph
print(p1)



subset(sahm, date >= as.Date('2019-01-01') & date <= as.Date('2021-01-01'))

# Save the plot as a PNG file
ggsave(dpi = "retina", plot = p1, "Sahm_Rule_Chart.png", type = "cairo-png",
       width = 10, height = 7, units = "in", bg = 'white')
