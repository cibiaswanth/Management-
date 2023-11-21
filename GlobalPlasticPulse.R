# Importing Libraries here.
library(tidyverse)
library(psych)
library(sf)
library(leaflet)
library(scales)

# Import data into R environment.
df_plastics_raw <- read_csv("./data/newplastics.csv")
continents_data <- read_csv("./data/continents-according-to-our-world-in-data.csv")
gdp_data <- read_csv("./data/2010GDP.csv")
my_shapefile <- st_read("./data/world-administrative-boundaries/world-administrative-boundaries.shp")

# Summarise structure of data 
str(df_plastics_raw)
sum(is.na(df_plastics_raw))

# NA values are Notes written by Author. No other NA Values.
which(!complete.cases(df_plastics_raw))

# Remove NA values at the bottom of data set as they are Notes (10 rows) written by the Author.
df_plastics <- df_plastics_raw %>% remove_missing()

# Edits in Plastics dataframe. 
df_plastics <- df_plastics %>% 
  mutate(Country = gsub("8$", "", Country))

df_plastics$`Mismanaged plastic waste [kg/person/day]7` <- df_plastics$`Mismanaged plastic waste [kg/person/day]7` %>% 
  as.numeric()

df_plastics$`Economic status1` <- factor(df_plastics$`Economic status1`, levels = c("LI", "LMI", "UMI", "HIC"),
                                            ordered = TRUE)
df_plastics <- df_plastics %>% mutate(`Economic status1` = case_when(
  `Economic status1` == "LI" ~ "Lower Income",
  `Economic status1` == "LMI" ~ "Lower Middle Income",
  `Economic status1` == "UMI" ~ "Upper Middle Income",
  `Economic status1` == "HIC" ~ "High Income",
  TRUE ~ NA_character_
))
# Edits in Continent dataframe.
names(continents_data)[1] <- "Country"

# Data Preprocessing. 
df_plastics$Country <- gsub("&", "and", df_plastics$Country)
df_plastics$Country <- gsub("[[:punct:]]", "", df_plastics$Country)
df_plastics$Country <- trimws(df_plastics$Country)
df_plastics$Country <- gsub("BurmaMyanmar", "Myanmar", df_plastics$Country)

continents_data$Country <- gsub("&", "and", continents_data$Country)
continents_data$Country <- gsub("[[:punct:]]", "", continents_data$Country)
continents_data$Country <- trimws(continents_data$Country)
df_plastics <- df_plastics %>% filter(Country != "Dhekelia")

old_names <- c("Congo Dem rep of", "Congo Rep of", "East Timor",
               "Faroe Islands", "Korea North", "Korea South Republic of Korea",
               "Micronesia", "Palestine Gaza Strip is only part on the coast",
               "Saint Maarten DWI", "Saint Pierre", "Svalbard", "The Gambia",
               "USVI")

new_names <- c("Democratic Republic of Congo", "Congo", "Timor", "Faeroe Islands",
               "North Korea", "South Korea", "Micronesia country", "Palestine",
               "Saint Martin French part", "Saint Pierre and Miquelon",
               "Svalbard and Jan Mayen", "Gambia", "United States Virgin Islands")

df_plastics <- df_plastics %>%
  mutate(Country = if_else(Country %in% old_names, new_names[match(Country, old_names)], Country))

df_plastics <- merge(df_plastics, continents_data, all.x = TRUE)

df_plastics <- df_plastics[, -which(names(df_plastics) == "Year")]
df_plastics$Continent <- df_plastics$Continent %>% as.factor()

gdp_data <- gdp_data %>% filter(Year == 2010)

# Final Data frame stucture
dim(df_plastics)
str(df_plastics)
summary(df_plastics)



# Load world data

my_shapefile <- my_shapefile %>% filter(!name %in% c("Azores Islands", "Gaza Strip")) %>% 
  mutate(center = st_centroid(geometry))
df_plastics <- merge(df_plastics, my_shapefile, by.x = "Code", by.y = "iso3", all.x = TRUE)
df_plastics <- merge(df_plastics, gdp_data, by.x = "Code", by.y = "Code", all.x = TRUE)
df_plastics %>% group_by(Country) %>% summarise(n = n()) %>% arrange(desc(n))

sf_plastics <- df_plastics %>% 
  st_as_sf()

pal <- colorNumeric(palette = "YlOrBr", domain = sf_plastics$`% Inadequately managed waste5`)
pal2 <- colorNumeric(palette = "YlOrRd", domain = log(sf_plastics$`Plastic waste generation [kg/day]7`))

# Prepare the text for tooltips:
mytext <- paste(
  "Country: ", sf_plastics$Country,"<br/>", 
  "Waste Generated: ", comma(sf_plastics$`Plastic waste generation [kg/day]7`, big.mark = ","), " kg/day<br/>", 
  "Mismanaged Waste: ", comma(sf_plastics$`Inadequately managed plastic waste [kg/day]7`, big.mark = ","), " kg/day<br/>",
  "Group: ", sf_plastics$`Economic status1`, "<br/>",
  "GDP: ", comma(sf_plastics$`GDP (constant 2015 US$)`, big.mark = ","), "<br/>",  
  sep="") %>%
  lapply(htmltools::HTML)


# Final Plot
leaflet() %>% 
  addProviderTiles(providers$CartoDB.Positron)  %>% 
  addPolygons(
    data = sf_plastics
    , fillColor = ~pal(`% Inadequately managed waste5`)
    , stroke=TRUE
    , fillOpacity = 1
    , color="white"
    , weight=0.3
    , label = mytext
    , labelOptions = labelOptions( 
      style = list("font-weight" = "normal", padding = "3px 8px"), 
      textsize = "13px", 
      direction = "auto"
    ),
    highlightOptions = highlightOptions(
      weight = 1,
      color = "black",
      fillOpacity = 0.5,
      bringToFront = TRUE
    )
  ) %>% 
  addLegend("bottomleft", pal = pal, values = ~`% Inadequately managed waste5`,
            title = "Mismanaged waste",
            labFormat = labelFormat(suffix = "%"),
            opacity = 1
            , data = sf_plastics
  )


