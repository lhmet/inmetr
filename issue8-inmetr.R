# https://github.com/lhmet/inmetr/issues/8

usethis::use_build_ignore("issue8-inmetr.R")
usethis::use_git_ignore("issue8")

# ctrl + s, to save this file
# maybe in the future put this test in /test with testthat

# devtools::install_github("lhmet/inmetr", force = TRUE)

# Installing package into ‘/home/hidrometeorologista/.R/libs’
# (as ‘lib’ is unspecified)
# * installing *source* package ‘inmetr’ ...
# ** using staged installation
# ** R
# ** data
# *** moving datasets to lazyload DB
# ** inst
# ** byte-compile and prepare package for lazy loading
# Note: wrong number of arguments to 'seq_along'             <---------------???
# ** help
# *** installing help indices
# ** building package indices
# ** testing if installed package can be loaded from temporary location
# ** testing if installed package can be loaded from final location
# ** testing if installed package keeps a record of temporary installation path
# * DONE (inmetr)

pcks <- c("devtools", "inmetr")
easypackages::libraries(pcks)

# ------------------------------------------------------------------------------
# Normal test
stations <- c("Santa Maria", "Macapá")
# random sample of two stations names 
#stations <- sample(bdmep_meta$name, 2)
stations_rows <- pmatch(stations, bdmep_meta$name)
bdmep_meta[stations_rows, ]
#>        id       lon    lat   alt        name             state uf
#> 320 83936 -53.70000 -29.70 95.00 Santa Maria Rio Grande do Sul RS
#> 31  82098 -51.11667  -0.05 14.46      Macapá             Amapá AP
#>             time_zone offset_utc       time_zone.1 offset_utc.1
#> 320 America/Sao_Paulo         -3 America/Sao_Paulo           -3
#> 31      America/Belem         -3     America/Belem           -3
stns_codes <- bdmep_meta[stations_rows, "id"] 
stns_codes

start_date <- "01/01/1961"
end_date <- format(Sys.Date(), "%d/%m/%Y")
met_data <- bdmep_import(id = stns_codes,
                         sdate = start_date, 
                         edate = end_date, 
                         email = "jdtatsch@gmail.com",
                         passwd = "d17ulev5",
                         verbose = TRUE)

# that's fine

# ------------------------------------------------------------------------------

stations <- c("Rio de Janeiro", "São Paulo (Mir. de Santana)", "Belo Horizonte",
              "Porto Alegre", "Florianópolis", "Vitória", "Curitiba",
              "Goiás", "Rio Branco", "Manaus", "Brasília", "Campo Grande",
              "Recife (Curado)", "Natal", "Aracaju", "Salvador (Ondina)",
              "Palmas", "Fortaleza", "São Luis", "Cuiabá",
              "João Pessoa", "Teresina", "Porto Velho", "Boa Vista",
              "Belém", "Macapá")

stations_rows <- pmatch(stations, bdmep_meta$name)
bdmep_meta[stations_rows, ]

stns_codes <- bdmep_meta[stations_rows, "id"]

stns_codes

(start_date <- "01/01/2018")
(end_date <- format(Sys.Date(), "%d/%m/%Y"))

met_data <- bdmep_import(id = stns_codes[c(1, 8, 12, 17)],
                         sdate = start_date,
                         edate = end_date,
                         email = "jdtatsch@gmail.com",
                         passwd = "d17ulev5",
                         verbose = TRUE)


stns_codes[c(1, 8, 12, 17)]

# stations with the same error
#station: 83860
#OK (HTTP 200).
#Error in (rowheader + 1):(length(x) - 1) : argument of length 0


