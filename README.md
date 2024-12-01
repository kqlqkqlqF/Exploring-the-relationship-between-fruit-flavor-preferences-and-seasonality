# Modeling Price Change of Seasonal Fruits Flavored Food Products: A Predictive Analysis

## Overview

This study develops a model to predict price changes for seasonal fruit-flavored products during in-season and off-season periods. It forecasts price increases for strawberry and banana-flavored products after November, with a larger rise for strawberry. This repository provides all the materials for this study, including scripts, data, models, and the paper.

## File Structure

The repo is structured as:

-   `data/00-simulated_data` contains the simulated price change data for banana-flavored and strawberry-flavored products from June 2024 to November 2024.
-   `data/01-raw_data` contains the raw data, which obtained from "https://jacobfilipp.com/hammer/" and openDataToronto.
-   `data/02-analysis_data` contains the cleaned dataset that was constructed.
-   `model` contains a series of fitted models. 
-   `other` contains relevant details about LLM chat histories, datasheet, and sketches for the figures demonstrated in the paper.
-   `paper` contains the files used to generate the paper, including the Quarto document and reference bibliography file, as well as the PDF of the paper. 
-   `scripts` contain the R scripts used to simulate, download, test, and clean data.

## Data Retrieval

We obtained the raw data from Jacob Filipp's Project Hammer website, available at: [https://jacobfilipp.com/hammer/](https://jacobfilipp.com/hammer/). To access the data, scroll down the page until you see the heading "Get Full Data in 2 CSV Files". Click on the link labeled "Zipped CSVs with full price data" to download the raw data. After extracting the files, you will obtain two CSV files: hammer-4-product.csv and hammer-4-raw.csv. Next, place these two files in the project's data/01-raw_data folder, and you’ll be able to run the code without issues.

## Statement on LLM usage

Aspects of the code and introduction were written with the help of Chatgpt4.0, the entire chat history is available at other/llm_usage/usage.txt.

