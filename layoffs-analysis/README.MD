# Layoffs Data Cleaning and Exploratory Analysis

## Overview

This project uses SQL to clean and analyze a layoffs dataset. The goal of this project was to prepare the data for analysis, then explore layoff trends by company, industry, country, year, and month.

The project is split into two main parts:

1. Data cleaning
2. Exploratory data analysis

## Tools Used

- MySQL
- MySQL Workbench
- GitHub

## SQL Skills Demonstrated

- Creating staging tables
- Removing duplicates
- Standardizing text values
- Handling null and blank values
- Removing unnecessary columns
- SELECT statements
- WHERE filtering
- GROUP BY
- ORDER BY
- Aggregate functions such as SUM(), MAX(), and AVG()
- Date functions
- CTEs
- Window functions
- DENSE_RANK()
- Rolling totals

## Project Files

- `layoffs_data_cleaning.sql`  
  Contains SQL queries used to clean and prepare the dataset.

- `layoffs_exploratory_analysis.sql`  
  Contains SQL queries used to explore layoff trends and answer analysis questions.

## Questions Answered

This project answers questions such as:

- Which companies had the highest total layoffs?
- Which industries had the most layoffs?
- Which countries had the most layoffs?
- Which years had the highest number of layoffs?
- What were the monthly layoff trends?
- How did layoffs change over time using rolling totals?
- Which companies ranked highest for layoffs in each year?

## Cleaning Process

The cleaning portion includes:

- Creating a staging table
- Identifying and removing duplicate records
- Standardizing company, industry, and country values
- Converting date values into a usable format
- Handling null and blank values
- Removing columns that were no longer needed

## Key Takeaway

This project helped me practice a full SQL workflow: cleaning raw data, preparing it for analysis, writing exploratory queries, summarizing results, ranking data, and identifying trends over time.

## Status

Completed as part of my SQL portfolio.
