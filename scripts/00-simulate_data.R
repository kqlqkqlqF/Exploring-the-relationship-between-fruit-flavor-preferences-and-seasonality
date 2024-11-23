#### Preamble ####
# Purpose: Simulate datasets for pomegranate, watermelon and rain data
  #state and party that won each division.
# Author: Yiyi Feng
# Date: 27 November 2024
# Contact: yiyi.feng@mail.utoronto.ca
# License: MIT
# Pre-requisites: The `tidyverse`, arrow` package must be installed
# Any other information needed?


#### Workspace setup ####
library(tidyverse)
library(arrow)

set.seed(333)

# Create the simulate_rain data frame
simulated_rain <- data.frame(
  month = 6:11,  # Months June (6) to November (11)
  num_data = c(150, 160, 150, 140, 165, 155)  # Simulated number of data points for each month
)

# Simulate total rainfall (random values between 50 and 200 mm for each month)
simulated_rain$total_rainfall <- sample(50:200, size = 6, replace = TRUE)

# Calculate average rainfall for each month
simulated_rain$avg_rainfall <- simulated_rain$total_rainfall / simulated_rain$num_data

# Generate random product names for watermelon snacks, drinks, and fruit
product_names_watermelon <- c(
  "Seedless Watermelon", "Watermelon Flavored Drink", "Watermelon Flavored Gummy", 
  "Watermelon Popsicle", "Watermelon Juice", "Watermelon Slices", 
  "Watermelon Candy", "Sparkling Watermelon Beverage", "Watermelon Sorbet", 
  "Watermelon Cake", "Watermelon Jam"
)

# Map product_name to category
category_mapping_watermelon <- c(
  "Seedless Sweet Baby Mini Watermelon" = "fruit",
  "Watermelon Flavored Tea Drink" = "beverage",
  "Watermelon Flavored Gummy" = "solid snack",
  "Watermelon Popsicle" = "solid snack",
  "Watermelon Apple Flavored Juice" = "beverage",
  "Watermelon Slices" = "fruit",
  "Watermelon Candy" = "solid snack",
  "Sparkling Watermelon Beverage" = "beverage",
  "Watermelon Sorbet" = "solid snack",
  "Watermelon Cake" = "solid snack",
  "Watermelon Jam" = "solid snack"
)

# Generate random IDs for watermelon
n <- 1000  # Adjust this as needed
watermelon_ids <- sample(1:10000000, size = n, replace = FALSE)

simulated_data_watermelon <- data.frame(
  id = watermelon_ids,
  vendor = sample(c("Voila", "Loblaws", "Metro", "Walmart", "NoFrills", "SaveOnFoods"), size = n, replace = TRUE),
  product_name = sample(product_names_watermelon, size = n, replace = TRUE)
)

# Add the category column based on product_name
simulated_data_watermelon$category <- category_mapping_watermelon[simulated_data_watermelon$product_name]

# Simulate average prices for June to November
for (month in c("June", "July", "August", "September", "October", "November")) {
  simulated_data_watermelon[[paste0("avg_price_", month)]] <- 
    ifelse(runif(n) > 0.8, NA, runif(n, min = 1, max = 20))  # 20% chance of NA
}

# Simulate product_data_pomegranate
set.seed(456)  # Seed for pomegranate data

# Generate random product names for pomegranate snacks, drinks, and fruit
product_names_pomegranate <- c(
  "Fresh Pomegranate", "Pomegranate Flavored Drink", "Pomegranate Flavored Candy",
  "Pomegranate Popsicle", "Pomegranate Juice", "Pomegranate Seeds",
  "Pomegranate Sorbet", "Pomegranate Jam", "Pomegranate Granola Bar",
  "Pomegranate Cake", "Pomegranate Smoothie"
)

# Map product_name to category
category_mapping_pomegranate <- c(
  "Fresh Pomegranate" = "fruit",
  "Pomegranate Flavored Drink" = "beverage",
  "Pomegranate Flavored Candy" = "solid snack",
  "Pomegranate Popsicle" = "solid snack",
  "Pomegranate Juice" = "beverage",
  "Large Red Pomegranate" = "fruit",
  "Pomegranate Sorbet" = "solid snack",
  "Pomegranate Jam" = "solid snack",
  "Pomegranate Granola Bar" = "solid snack",
  "Pomegranate Cake" = "solid snack",
  "Pomegranate Smoothie" = "beverage"
)

# Generate random IDs for pomegranate, excluding watermelon IDs
pomegranate_ids <- sample(setdiff(1:10000000, watermelon_ids), size = n, replace = FALSE)

simulated_data_pomegranate <- data.frame(
  id = pomegranate_ids,
  vendor = sample(c("Voila", "Loblaws", "Metro", "Walmart", "NoFrills", "SaveOnFoods"), size = n, replace = TRUE),
  product_name = sample(product_names_pomegranate, size = n, replace = TRUE)
)

# Add the category column based on product_name
simulated_data_pomegranate$category <- category_mapping_pomegranate[simulated_data_pomegranate$product_name]

# Simulate average prices for June to November
for (month in c("June", "July", "August", "September", "October", "November")) {
  simulated_data_pomegranate[[paste0("avg_price_", month)]] <- 
    ifelse(runif(n) > 0.8, NA, runif(n, min = 1, max = 20))  # 20% chance of NA
}

#### Save data ####

# Save data as a Parquet file
write_parquet(simulated_rain, "data/00-simulated_data/simulated_rain_data.parquet")
write_parquet(simulated_data_pomegranate, "data/00-simulated_data/simulated_pomegranate_data.parquet")
write_parquet(simulated_data_watermelon, "data/00-simulated_data/simulated_watermelon_data.parquet")


