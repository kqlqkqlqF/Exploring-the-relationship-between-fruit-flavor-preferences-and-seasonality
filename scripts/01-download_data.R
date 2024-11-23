#### Preamble ####
# Purpose: Download temperature data from Opendatatoronto
# Author: Yiyi Feng
# Date: 27 November 2024
# Contact: yiyi.feng@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - The `opendatatoronto`, `dplyr` , `arrow`  package must be installed and loaded
# Any other information needed? 


library(opendatatoronto)
library(dplyr)
library(arrow)


# get package
package <- show_package("f2933501-0373-4734-b50c-4e4f39646180")
package

# get all resources for this package
resources <- list_package_resources("f2933501-0373-4734-b50c-4e4f39646180")

# identify datastore resources; by default, Toronto Open Data sets datastore resource format to CSV for non-geospatial and GeoJSON for geospatial resources
datastore_resources <- filter(resources, tolower(format) %in% c('csv', 'geojson'))

# load the first datastore resource as a sample
data <- filter(datastore_resources, row_number()==10) %>% get_resource()
data

# Save product_data_watermelon as a Parquet file
write_parquet(data, "data/01-raw_data/rainfall_data.parquet")





