# Visualization of Choropleth Map of Resident Population Density in Singapore

This repository contains a project focused on visualizing the resident population density across Singapore's planning areas through a choropleth map. The map is interactive and built using R's Shiny, leaflet, and geospatial data from the Singapore Department of Statistics and Urban Redevelopment Authority (URA). The project allows for an exploration of how population density changes over time and across different age groups.

## Authors
- Azreen
- Kai Jun
- Aloysius
- Irfan
- Beata

## Project Overview
This project visualizes the resident population density of Singapore using a choropleth map. The interactive map allows users to explore population data filtered by time (year) and age group. The goal is to provide insights into demographic changes and urban development across different regions.

### Key Features:
- **Interactive Shiny App**: Users can explore population data by planning area, year, and age group.
- **Geospatial Mapping**: The map integrates geospatial data (KML) with population data to display the density across Singapore's planning areas.
- **Hover Information**: Users can hover over specific planning areas to get real-time population statistics.

## Data Sources
- **Population Data**: Obtained from the [Singapore Department of Statistics](https://www.singstat.gov.sg/find-data/search-by-theme/population/geographic-distribution/latest-data). The dataset includes population counts by age group and planning area from 2000 to 2023.
- **Geospatial Data**: Planning area boundaries were sourced from the [Urban Redevelopment Authority (URA)](https://www.ura.gov.sg/maps/#master-plan)'s 2019 Master Plan in KML format.

## Suggested Improvements
Based on our analysis, here are a few areas where this project could be improved:
1. **Better Contrast**: Utilize high-contrast color schemes like Color Universal Design (CUD) to ensure accessibility for users with color vision impairments.
2. **Reduced Data Density**: Simplify data visualization by reducing the number of data points displayed at once, preventing overcrowding.
3. **Expanded Time Range**: Enable users to explore data from multiple years to analyze trends over time.
4. **Interactivity**: Implement dynamic filtering options for further exploration of population growth, elderly density, and other key metrics.

## Software and Libraries
- **R**: Core programming language used in this project.
- **Shiny**: Framework for building interactive web applications.
- **leaflet**: Library for interactive mapping.
- **sf**: Handles spatial data.
- **dplyr**: Used for data manipulation and cleaning.
- **readxl**, **tidyverse**: Libraries for reading and cleaning Excel data.

## Project Structure
The project is organized as follows:
- `data/`: Contains the KML file for Singapore’s planning areas and the population data CSV.
- `app.R`: The main R script containing the Shiny app, responsible for data processing and visualization.
- `README.md`: This file, providing an overview of the project.
- `images/`: Contains any relevant visualizations (e.g., choropleth map snapshots for reference).

## How to Run the Project
To run this project locally, follow these steps:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/choropleth-singapore-population.git
