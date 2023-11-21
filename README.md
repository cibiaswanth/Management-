# Management-

Waste Management Visualization Project:
Description:
This project focuses on visualizing global waste management statistics using R and Leaflet. It showcases country-specific waste generation, mismanagement rates, economic status, and GDP in a geographical context.

Requirements:
R
Libraries: tidyverse, psych, sf, leaflet, scales
Datasets
Plastics Data: Contains information about waste generation and mismanagement.
Continents Data: Provides the continent information for each country.
GDP Data: Includes GDP details for the year 2010.
Shapefile: World administrative boundaries shapefile for mapping.
Data Processing
Import: Reads CSV files and shapefiles into R.
Cleaning: Handles missing values, standardizes country names, and prepares data for visualization.
Transformation: Converts economic status categories, merges datasets, and prepares a unified data frame for mapping.
Leaflet Map
Map Configuration: Initializes a Leaflet map, adds map tiles, and configures visual properties.
Data Visualization: Plots country polygons with color-coding based on waste mismanagement percentages.
Tooltips: Provides detailed information about each country on hover.
Visualization Details
The map visualizes:

Mismanaged Waste: Displayed using color scales indicating percentages.
Waste Generation: Represented through color intensities on the map.
Country Information: Tooltip shows waste generated, economic status, and GDP.
Conclusion
The visual representation highlights patterns in waste management across countries, showcasing disparities in mismanagement rates, economic status, and waste generation.

Usage
Ensure R is installed on your system.
Install required libraries: tidyverse, psych, sf, leaflet, scales.
Execute the provided R script to generate the Leaflet map.
