# Estimation of Iranian Real Estate Units Sales Prices

This repository contains the code for the (group M) final project of A.Y. 2022-2023
Professor Nicola Torelli and Professor Gioia Di Credico's course on **Statistical
Methods for Data Science** at the University of Trieste in the A.Y. 2022-2023.


## Problem statement

It is required to analyze the [Residential Building Data Set](https://archive.ics.uci.edu/ml/datasets/Residential+Building+Data+Set),
containing data about Iranian real estate single-family residential apartments
constructions building data.\
More specifically, the request is to study possible statistical models to predict
`SalesPrice` as response variable, given the other explanatory variables.


## Organization of work

The project has been divided into sub-problems and resolved as follows:
* Enrico Stefanel ([@enstit](https://github.com/enstit)): problem statement,
  exploratory data analysis and data-cleaning phase;
* Cristian Curaba ([@Cristian-Curaba](https://github.com/Cristian-Curaba)):
  selection, description and comparison of most suitable models;
* Yaiza Martínez Jiménez: comments on results.


## Usage

The [.Rmd file](./estate_sales_prices_estimation.Rmd) contains all the project
analysis. A rendered version of it can be found into the [HTML file](./estate_sales_prices_estimation.html)
with the same name.\
In order to successfully run all the code, you need to install some R packages
(if not already installed on your system):

```R
install.packages('dplyr', 'openxlsx', 'ggplot2', 'AER', 'MASS', 'car', 'boot', 'randomForest')
```