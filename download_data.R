## download data 

####################
##### download #####
####################

zip_folder = "https://www.epicentro.iss.it/coronavirus/open-data/OPENDATA-2021.zip"

temp <- tempfile()
download.file(scrape_url, temp)
unzip(temp, exdir = here("data","data-raw-prova"))
unlink(temp)


## unzip ito folder
unzip(zipfile=scrape_url, exdir= here("data", "data-raw-prova"))

## TODO:
## - togliere la cartella OPENDATA (muovere 1 level upper)