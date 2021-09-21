library(rvest, warn.conflicts = F, quietly = T)
library(stringr, warn.conflicts = F, quietly = T)
library(httr, warn.conflicts = F, quietly = T)
library(glue, warn.conflicts = F, quietly = T)
library(here, warn.conflicts = F, quietly = T)
library(readr, warn.conflicts = F, quietly = T)
library(readxl, warn.conflicts = F, quietly = T)
library(tidyr, warn.conflicts = F, quietly = T)
library(dplyr, warn.conflicts = F, quietly = T)
library(purrr, warn.conflicts = F, quietly = T)
library(pins, warn.conflicts = F, quietly = T)
library(lubridate, warn.conflicts = F, quietly = T)
library(logger, warn.conflicts = F, quietly = T)



## MVP
## - prendi tutti i fogli excel e bindali
## - prendi ogni singola finestra
## - aggrega i dati per grafico
## - pinna i dati per ogni grafico


## board registering
board_register_github(repo = "Data-Network-Lab/dati-bollettino-sorveglianza")

paths <- list.files(here("data", "data-raw"), full.names = T)
sheets <- excel_sheets(paths[1])


read_table_excel <- function(path, sheet) {
  sheets <- sheets <- excel_sheets(path)

  read_excel(path, sheet) %>%
    bind_rows()
}

sheets <- excel_sheets(paths[1])


read_table_excel(paths[1:2], sheet = "sesso_eta")


map2_dfr(paths[1:3], sheets, read_table_excel)
