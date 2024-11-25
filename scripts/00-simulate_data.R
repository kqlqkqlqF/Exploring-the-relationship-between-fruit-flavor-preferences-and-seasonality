#### Preamble ####
# Purpose: Simulate datasets for strawberry, banana and rain data
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

# Generate random product names for banana snacks, drinks, and fruit
product_names_banana <- c(
  "Seedless banana", "banana Flavored Drink", "banana Flavored Gummy", 
  "banana Popsicle", "banana Juice", "banana Slices", 
  "banana Candy", "Sparkling banana Beverage", "banana Sorbet", 
  "banana Cake", "banana Jam"
)

# Map product_name to category
category_mapping_banana <- c(
  "Seedless Sweet Baby Mini banana" = "fruit",
  "banana Flavored Tea Drink" = "beverage",
  "banana Flavored Gummy" = "solid snack",
  "banana Popsicle" = "solid snack",
  "banana Apple Flavored Juice" = "beverage",
  "banana Slices" = "fruit",
  "banana Candy" = "solid snack",
  "Sparkling banana Beverage" = "beverage",
  "banana Sorbet" = "solid snack",
  "banana Cake" = "solid snack",
  "banana Jam" = "solid snack"
)

# Generate random IDs for banana
n <- 1000  # Adjust this as needed
banana_ids <- sample(1:10000000, size = n, replace = FALSE)

simulated_data_banana <- data.frame(
  id = banana_ids,
  vendor = sample(c("Voila", "Loblaws", "Metro", "Walmart", "NoFrills", "SaveOnFoods"), size = n, replace = TRUE),
  product_name = sample(product_names_banana, size = n, replace = TRUE)
)

# Add the category column based on product_name
simulated_data_banana$category <- category_mapping_banana[simulated_data_banana$product_name]

# Simulate average prices for June to November
for (month in c("June", "July", "August", "September", "October", "November")) {
  simulated_data_banana[[paste0("avg_price_", month)]] <- 
    ifelse(runif(n) > 0.8, NA, runif(n, min = 1, max = 20))  # 20% chance of NA
}

# Simulate product_data_strawberry
set.seed(456)  # Seed for strawberry data

# Generate random product names for strawberry snacks, drinks, and fruit
product_names_strawberry <- c(
  "Fresh strawberry", "strawberry Flavored Drink", "strawberry Flavored Candy",
  "strawberry Popsicle", "strawberry Juice", "strawberry Seeds",
  "strawberry Sorbet", "strawberry Jam", "strawberry Granola Bar",
  "strawberry Cake", "strawberry Smoothie"
)

# Map product_name to category
category_mapping_strawberry <- c(
  "Fresh strawberry" = "fruit",
  "strawberry Flavored Drink" = "beverage",
  "strawberry Flavored Candy" = "solid snack",
  "strawberry Popsicle" = "solid snack",
  "strawberry Juice" = "beverage",
  "Large Red strawberry" = "fruit",
  "strawberry Sorbet" = "solid snack",
  "strawberry Jam" = "solid snack",
  "strawberry Granola Bar" = "solid snack",
  "strawberry Cake" = "solid snack",
  "strawberry Smoothie" = "beverage"
)

# Generate random IDs for strawberry, excluding banana IDs
strawberry_ids <- sample(setdiff(1:10000000, banana_ids), size = n, replace = FALSE)

simulated_data_strawberry <- data.frame(
  id = strawberry_ids,
  vendor = sample(c("Voila", "Loblaws", "Metro", "Walmart", "NoFrills", "SaveOnFoods"), size = n, replace = TRUE),
  product_name = sample(product_names_strawberry, size = n, replace = TRUE)
)

# Add the category column based on product_name
simulated_data_strawberry$category <- category_mapping_strawberry[simulated_data_strawberry$product_name]

# Simulate average prices for June to November
for (month in c("June", "July", "August", "September", "October", "November")) {
  simulated_data_strawberry[[paste0("avg_price_", month)]] <- 
    ifelse(runif(n) > 0.8, NA, runif(n, min = 1, max = 20))  # 20% chance of NA
}

#### Save data ####

# Save data as a Parquet file
write_parquet(simulated_rain, "data/00-simulated_data/simulated_rain_data.parquet")
write_parquet(simulated_data_strawberry, "data/00-simulated_data/simulated_strawberry_data.parquet")
write_parquet(simulated_data_banana, "data/00-simulated_data/simulated_banana_data.parquet")


