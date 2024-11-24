#### Preamble ####
# Purpose: Tests the structure and validity of the simulated data
# Author: Yiyi Feng
# Date: 27 November 2024
# Contact: yiyi.feng@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
  # - The `tidyverse` and `arrow` package must be installed and loaded
  # - 00-simulate_data.R must have been run
# Any other information needed? No


#### Workspace setup ####
library(tidyverse)
library(arrow)

test_watermelon_data <- read_parquet("data/00-simulated_data/simulated_watermelon_data.parquet")
test_rain_data <- read_parquet("data/00-simulated_data/simulated_rain_data.parquet")
test_pomegranate_data <- read_parquet("data/00-simulated_data/simulated_pomegranate_data.parquet")


#### Test for Watermelon and Pomegranate Data ####

# Test: No overlapping IDs
test_unique_ids <- function(watermelon_data, pomegranate_data) {
  common_ids <- intersect(watermelon_data$id, pomegranate_data$id)
  if (length(common_ids) == 0) {
    cat("Test passed: No overlapping IDs between watermelon and pomegranate data.\n")
  } else {
    stop("Test failed: Overlapping IDs found.")
  }
}

test_unique_ids(test_watermelon_data, test_pomegranate_data)


# Test: Vendor values are valid
test_valid_vendors <- function(data) {
  allowed_vendors <- c("Voila", "Loblaws", "Metro", "Walmart", "NoFrills", "SaveOnFoods")
  invalid_vendors <- setdiff(unique(data$vendor), allowed_vendors)
  if (length(invalid_vendors) == 0) {
    cat("Test passed: All vendors are valid.\n")
  } else {
    stop(paste("Test failed: Invalid vendors found:", paste(invalid_vendors, collapse = ", ")))
  }
}

test_valid_vendors(test_watermelon_data)
test_valid_vendors(test_pomegranate_data)


# Test: Check column count for product_data_watermelon
if (ncol(test_watermelon_data) == 10) {
  cat("Test Passed: product_data_watermelon has 10 columns.")
} else {
  stop(paste("Test Failed: product_data_watermelon has", ncol(test_watermelon_data), "columns; expected 10 columns."))
}

# Test: Check column count for product_data_pomegranate
if (ncol(test_pomegranate_data) == 10) {
  cat("Test Passed: product_data_pomegranate has 10 columns.")
} else {
  stop(paste("Test Failed: product_data_pomegranate has", ncol(test_pomegranate_data), "columns; expected 10 columns."))
}


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


# Test: Product names map correctly to categories
test_product_category_mapping <- function(data, category_mapping) {
  incorrect_mappings <- data %>%
    filter(category != category_mapping[product_name]) %>%
    select(id, product_name, category)
  if (nrow(incorrect_mappings) == 0) {
    cat("Test passed: All product names map correctly to categories.\n")
  } else {
    stop("Test failed: Incorrect product name-category mappings found.")
  }
}

test_product_category_mapping(test_watermelon_data, category_mapping_watermelon)
test_product_category_mapping(test_pomegranate_data, category_mapping_pomegranate)


# Test: Average prices are within range or NA
test_avg_prices <- function(data) {
  price_cols <- grep("^avg_price_", names(data), value = TRUE)
  invalid_prices <- data %>%
    select(all_of(price_cols)) %>%
    filter(if_any(everything(), ~ !is.na(.) & (. < 1 | . > 20)))
  if (nrow(invalid_prices) == 0) {
    cat("Test passed: All average prices are within the valid range or NA.\n")
  } else {
    stop("Test failed: Invalid average prices found.")
  }
}

test_avg_prices(test_watermelon_data)
test_avg_prices(test_pomegranate_data)


#### Test for Rain Data ####

# Test: Check if the dataset has 6 rows and 4 columns
if (nrow(test_rain_data) == 6 && ncol(test_rain_data) == 4) {
  cat("Test Passed: test_rain_data has 6 rows and 4 columns.")
} else {
  stop(paste("Test Failed: test_rain_data has", nrow(test_rain_data), "rows and", ncol(test_rain_data), "columns; expected 6 rows and 4 columns."))
}

# Test: Check if the 'month' column contains 6, 7, 8, 9, 10, and 11
expected_months <- 6:11
if (all(sort(test_rain_data$month) == expected_months)) {
  cat("Test Passed: test_rain_data 'month' column contains the expected months: 6, 7, 8, 9, 10, 11.")
} else {
  stop(paste("Test Failed: test_rain_data 'month' column does not contain the expected months. Found:", paste(sort(unique(test_rain_data$month)), collapse = ", "), "."))
}

# Test: Check if `total_rainfall / num_data` equals `avg_rainfall` for each row
calculated_avg_rainfall <- round(test_rain_data$total_rainfall / test_rain_data$num_data, 2)
if (all(round(test_rain_data$avg_rainfall, 2) == calculated_avg_rainfall)) {
  cat("Test Passed: avg_rainfall values are correctly calculated as total_rainfall / num_data.")
} else {
  stop("Test Failed: avg_rainfall values are not correctly calculated as total_rainfall / num_data.")
}

# Test: Check if there are any NA values in the dataset
if (all(!is.na(test_rain_data))) {
  cat("Test Passed: test_rain_data has no NA values.")
} else {
  stop("Test Failed: test_rain_data contains NA values.")
}


  