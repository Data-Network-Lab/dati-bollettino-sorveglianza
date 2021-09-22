## download data

####################
##### download #####
####################

zip_folder <- "https://www.epicentro.iss.it/coronavirus/open-data/OPENDATA-2021.zip"

temp <- tempfile()
download.file(zip_folder, temp)
unzip(temp, exdir = here("data"))
unlink(temp)


## TODO:
## - togliere la cartella OPENDATA (muovere 1 level upper)
