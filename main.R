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
## - prendi tutti i fogli excel e bindali DONE
## - prendi ogni singola finestra (sheet) DONE
## - aggrega i dati per grafico
## - pinna i dati per ogni grafico DONE


## board registering
board_register_github(repo = "Data-Network-Lab/dati-bollettino-sorveglianza", branch = "master")

paths <- list.files(here("data", "OPENDATA"), full.names = T)
sheets <- excel_sheets(paths[1])

# c("Nota metodologica", "Contenuto", "casi_prelievo_diagnosi","casi_inizio_sintomi",
# "casi_inizio_sintomi_sint","casi_regioni","casi_provincie","ricoveri","decessi",
# "sesso_eta", "stato_clinico")


read_table_excel <- function(path, sheet) {
  sheets <- excel_sheets(path)

  read_excel(path, sheet) %>%
    bind_rows()
}

## TODO
## - plan a future backend
## - add a mapper function

sesso_eta <- map_dfr(paths, read_table_excel, sheet = "sesso_eta") %>% pin(name = "data/sesso_eta_data", description = "pin sesso_eta data", board = "github")

stato_clinico <- map_dfr(paths, read_table_excel, sheet = "stato_clinico") %>% pin(name = "data/stato_clinico_data", description = "pin stato_clinico data", board = "github")
decessi <- map_dfr(paths, read_table_excel, sheet = "decessi") %>% pin(name = "data/decessi_data", description = "pin decessi data", board = "github")
ricoveri <- map_dfr(paths, read_table_excel, sheet = "ricoveri") %>% pin(name = "data/ricoveri_data", description = "pin ricoveri data", board = "github")
casi_provincie <- map_dfr(paths, read_table_excel, sheet = "casi_provincie") %>% pin(name = "data/casi_provincie_data", description = "pin casi_provincie data", board = "github")
casi_regioni <- map_dfr(paths, read_table_excel, sheet = "casi_regioni") %>% pin(name = "data/casi_regioni_data", description = "pin casi_regioni data", board = "github")
casi_inizio_sintomi_sint <- map_dfr(paths, read_table_excel, sheet = "casi_inizio_sintomi_sint") %>% pin(name = "data/casi_inizio_sintomi_sint_data", description = "pin casi_inizio_sintomi_sint data", board = "github")
casi_inizio_sintomi <- map_dfr(paths, read_table_excel, sheet = "casi_inizio_sintomi") %>% pin(name = "data/casi_inizio_sintomi_data", description = "pin casi_inizio_sintomi data", board = "github")
casi_prelievo_diagnosi <- map_dfr(paths, read_table_excel, sheet = "casi_prelievo_diagnosi") %>% pin(name = "data/casi_prelievo_diagnosi_data", description = "pin casi_prelievo_diagnosi data", board = "github")
