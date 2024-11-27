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
  month = 7:11,  # Months June (6) to November (11)
  num_data = c(150, 160, 150, 140, 165, 155)  # Simulated number of data points for each month
)

# Simulate total rainfall (random values between 50 and 200 mm for each month)
simulated_rain$total_rainfall <- sample(50:200, size = 5, replace = TRUE)

# Calculate average rainfall for each month
simulated_rain$avg_rainfall <- simulated_rain$total_rainfall / simulated_rain$num_data

# Generate random product names for banana snacks, drinks, and fruit
product_names_banana <- c(
  "Seedless banana", "banana Flavored Drink", "banana Flavored Gummy", 
  "banana Popsicle", "banana Apple Flavored tea", "banana Slices", 
  "banana Candy", "banana yogurt", "banana Sorbet", 
  "banana Cake", "banana Jam"
)

# Map product_name to category
category_mapping_banana <- c(
  "Seedless Sweet Baby Mini banana" = "Fruit",
  "banana Flavored Drink" = "Beverage",
  "banana Flavored Gummy" = "Solid snack",
  "banana Popsicle" = "Solid snack",
  "banana Apple Flavored tea" = "Flavored Tea",
  "banana Slices" = "Fruit",
  "banana Candy" = "Solid snack",
  "banana yogurt" = "Yogurt",
  "banana Sorbet" = "Solid snack",
  "banana Cake" = "Solid snack",
  "banana Jam" = "Solid snack"
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
  "Fresh strawberry", "strawberry Flavored Tea", "strawberry Flavored Candy",
  "strawberry Popsicle", "strawberry Juice", "Large Red strawberry",
  "strawberry Sorbet", "strawberry Jam", "strawberry Granola Bar",
  "strawberry Yogurt", "strawberry Smoothie"
)

# Map product_name to category
category_mapping_strawberry <- c(
  "Fresh strawberry" = "Fruit",
  "strawberry Flavored Tea" = "Flavored Tea",
  "strawberry Flavored Candy" = "Solid snack",
  "strawberry Popsicle" = "Solid snack",
  "strawberry Juice" = "Beverage",
  "Large Red strawberry" = "Fruit",
  "strawberry Sorbet" = "Solid snack",
  "strawberry Jam" = "Solid snack",
  "strawberry Granola Bar" = "Solid snack",
  "strawberry Yogurt" = "Yogurt",
  "strawberry Smoothie" = "Beverage"
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


