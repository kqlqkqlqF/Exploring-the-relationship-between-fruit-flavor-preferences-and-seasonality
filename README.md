# Modeling Price Change of Seasonal Fruits Flavored Food Products: A Predictive Analysis

## Overview

This study presents a predictive framework for the 2024 U.S. presidential election, focusing on the competition between Donald Trump and Kamala Harris. Polling data aggregated by FiveThirtyEight is used to develop a linear model that predicts the probability of Donald Trump winning the 2024 U.S. presidential election, expressed in voter support rates. This repository provides all the materials for this study, including scripts, data, models, and the paper.

## File Structure

The repo is structured as:

-   `data/00-simulated_data` contains the simulated 2024 US presidential election poll data.
-   `data/01-raw_data` contains the raw data, which obtained from "https://projects.fivethirtyeight.com/polls/president-general/2024/national/".
-   `data/02-analysis_data` contains the cleaned dataset that was constructed.
-   `model` contains a series of fitted models. 
-   `other` contains relevant details about LLM chat histories, and sketches for the figures demonstrated in the paper.
-   `paper` contains the files used to generate the paper, including the Quarto document and reference bibliography file, as well as the PDF of the paper. 
-   `scripts` contain the R scripts used to simulate, download, and clean data.

## Data Retrieval

Polling outcome data can be accessed from FiveThirtyEight's presidential polling page. To download the data, look for the “Download the data” link on the page. From there, select “Presidential general election polls (current cycle)” and click the Download button.

## Statement on LLM usage

Aspects of the code and introduction were written with the help of Chatgpt4.0, the entire chat history is available at other/llm_usage/usage.txt.

