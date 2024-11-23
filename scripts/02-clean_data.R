#### Preamble ####
# Purpose: Cleans the raw data
# Author: Yiyi Feng
# Date: 27 November 2024
# Contact: yiyi.feng@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - The `tidyverse`, `janitor` , `arrow` , `lubridate`  package must be installed and loaded
# Any other information needed? No

#### Workspace setup ####
library(tidyverse)
library(janitor)
library(arrow)
library(lubridate)

#### Clean data ####
# read the dataset
raw_data <- read_csv("data/01-raw_data/hammer-4-raw.csv")
product_data <- read_csv("data/01-raw_data/hammer-4-product.csv")

# Read the Parquet file
rain_data <- read_parquet("data/01-raw_data/rainfall_data.parquet")


# Filter rows where 'product_name' contains 'watermelon' (case-insensitive)
product_data_watermelon <- product_data[grepl("watermelon", product_data$product_name, ignore.case = TRUE), ]

# Remove rows where 'product_name' or 'concatted' contains 'yogurt' (case-insensitive)
product_data_watermelon <- product_data_watermelon %>%
  filter(!grepl("yogurt", product_name, ignore.case = TRUE) & 
           !grepl("yogurt", concatted, ignore.case = TRUE) & 
           !grepl("tea bag", product_name, ignore.case = TRUE) & 
           !grepl("tea bag", concatted, ignore.case = TRUE) &
           !grepl("teabag", product_name, ignore.case = TRUE) & 
           !grepl("teabag", concatted, ignore.case = TRUE))

# Create a new column 'category' based on conditions in product_name and concatted columns
product_data_watermelon$category <- ifelse(
  grepl("\\d+(ML|ml|L|l)", product_data_watermelon$product_name) | 
    grepl("\\d+(ML|ml|L|l)", product_data_watermelon$concatted), "Beverage",
  ifelse(
    grepl("\\d+(g|G|kg|KG)", product_data_watermelon$product_name) | 
      grepl("\\d+(g|G|kg|KG)", product_data_watermelon$concatted), "Solid Snacks",
    "Fruit"
  )
)

# Remove the specified columns from the dataset
product_data_watermelon <- product_data_watermelon %>%
  select(-concatted, -units, -brand, -detail_url, -sku, -upc)


# Create product_data_pomegranate with rows that contain 'Pomegranate' in product_name
product_data_pomegranate <- product_data %>%
  filter(grepl("Pomegranate", product_name, ignore.case = TRUE))

# Remove rows where 'product_name' or 'concatted' contains 'yogurt' (case-insensitive)
product_data_pomegranate <- product_data_pomegranate %>%
  filter(!grepl("yogurt", product_name, ignore.case = TRUE) & 
           !grepl("yogurt", concatted, ignore.case = TRUE) & 
           !grepl("tea bag", product_name, ignore.case = TRUE) & 
           !grepl("tea bag", concatted, ignore.case = TRUE) &
           !grepl("teabag", product_name, ignore.case = TRUE) & 
           !grepl("teabag", concatted, ignore.case = TRUE))

# Create a new column 'category' based on conditions in product_name and concatted columns
product_data_pomegranate$category <- ifelse(
  grepl("\\d+(ML|ml|L|l)", product_data_pomegranate$product_name) | 
    grepl("\\d+(ML|ml|L|l)", product_data_pomegranate$concatted), "Beverage",
  ifelse(
    grepl("\\d+(g|G|kg|KG)", product_data_pomegranate$product_name) | 
      grepl("\\d+(g|G|kg|KG)", product_data_pomegranate$concatted), "Solid Snacks",
    "Fruit"
  )
)

# Remove the specified columns
product_data_pomegranate <- product_data_pomegranate %>%
  select(-concatted, -units, -brand, -detail_url, -sku, -upc)

# Filter rows in raw_data where product_id is contained in the 'id' column of either product_data_watermelon or product_data_pomegranate
raw_data <- raw_data %>%
  filter(product_id %in% c(product_data_watermelon$id, product_data_pomegranate$id))

raw_data <- raw_data %>%
  filter(!is.na(price_per_unit))

# Convert 'nowtime' to Date format, keeping only the date part
raw_data$nowtime <- as.Date(raw_data$nowtime)

# Remove specified columns from raw_data
raw_data <- raw_data[, !colnames(raw_data) %in% c("old_price", "price_per_unit", "other")]

# Rank rows by nowtime for each product_id
raw_data <- raw_data %>%
  group_by(product_id) %>%
  arrange(product_id, nowtime) %>%
  mutate(rank = row_number()) %>%
  ungroup()

raw_data <- raw_data %>% 
  select(-rank)

raw_data <- raw_data %>% distinct()

# Function to fill missing dates for each product_id
fill_missing_dates <- raw_data %>%
  group_by(product_id) %>%
  # Generate a sequence of all dates between the min and max dates for each product_id
  complete(nowtime = seq(min(nowtime), max(nowtime), by = "day")) %>%
  # Fill 'current_price' with the last known price
  arrange(product_id, nowtime) %>%
  fill(current_price, .direction = "down") %>%
  ungroup()


fill_missing_dates$current_price <- as.numeric(fill_missing_dates$current_price)

fill_missing_dates <- na.omit(fill_missing_dates)

# List of months from June to November
months <- 6:11
month_names <- c("June", "July", "August", "September", "October", "November")

# Step 4: Loop through each month and calculate the average price for each product_id
for(i in 1:length(months)) {
  month_num <- months[i]
  month_name <- month_names[i]
  
  # Calculate the average price for the specific month
  avg_price_month <- fill_missing_dates %>%
    filter(month(nowtime) == month_num) %>%
    group_by(product_id) %>%
    summarise(!!paste0("avg_price_", month_name) := mean(current_price, na.rm = TRUE)) %>%
    ungroup()
  
  # Step 5: Merge the calculated average price for the month into product_data_watermelon
  product_data_watermelon <- product_data_watermelon %>%
    left_join(avg_price_month, by = c("id" = "product_id"))
}


# Step 4: Loop through each month and calculate the average price for each product_id
for(i in 1:length(months)) {
  month_num <- months[i]
  month_name <- month_names[i]
  
  # Calculate the average price for the specific month
  avg_price_month <- fill_missing_dates %>%
    filter(month(nowtime) == month_num) %>%
    group_by(product_id) %>%
    summarise(!!paste0("avg_price_", month_name) := mean(current_price, na.rm = TRUE)) %>%
    ungroup()
  
  # Step 5: Merge the calculated average price for the month into product_data_pomegranate
  product_data_pomegranate <- product_data_pomegranate %>%
    left_join(avg_price_month, by = c("id" = "product_id"))
}

# For product_data_watermelon
product_data_watermelon <- product_data_watermelon %>%
  # Remove rows where all avg_price columns are NA
  filter(rowSums(is.na(select(., avg_price_June:avg_price_November))) < ncol(select(., avg_price_June:avg_price_November)))

# For product_data_pomegranate
product_data_pomegranate <- product_data_pomegranate %>%
  # Remove rows where all avg_price columns are NA
  filter(rowSums(is.na(select(., avg_price_June:avg_price_November))) < ncol(select(., avg_price_June:avg_price_November)))

# Save product_data_watermelon as a Parquet file
write_parquet(product_data_watermelon, "data/02-analysis_data/watermelon_data.parquet")
# Save product_data_pomegranate as a Parquet file
write_parquet(product_data_pomegranate, "data/02-analysis_data/pomegranate_data.parquet")

# Keep only the 'dataCollectionDate' and 'airTemp' columns
rain_data <- rain_data %>%
  select(date, rainfall)

# Convert the 'date' column to date format
rain_data$date <- as.Date(rain_data$date)

# Filter rows for dates between June 2024 and November 2024
rain_data_filtered <- rain_data %>%
  filter(date >= "2024-06-01" & date <= "2024-11-30")

# Extract month and year
rain_data_filtered$month <- month(rain_data_filtered$date)
rain_data_filtered$year <- year(rain_data_filtered$date)

# Filter for months between June and November 2024
rain_data_filtered <- rain_data_filtered %>%
  filter(year == 2024 & month >= 6 & month <= 11)

# Calculate the average rainfall for each month
average_rainfall <- rain_data_filtered %>%
  group_by(month) %>%
  summarise(
    total_rainfall = sum(rainfall, na.rm = TRUE),
    num_data = n(),
    avg_rainfall = total_rainfall / num_data
  )




# Save data_rain as a Parquet file
write_parquet(average_rainfall, "data/02-analysis_data/average_rain_data.parquet")

