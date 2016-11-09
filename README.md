inmetr
================

inmetr: A R-package to Import Historical Data from Brazilian Meteorological Stations
====================================================================================

[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.59652.svg)](http://dx.doi.org/10.5281/zenodo.59652) [![Version](https://img.shields.io/badge/Version-0.0.1-orange.svg)](https://img.shields.io/badge/Version-0.0.1-orange.svg)

Overview
--------

`inmetr` provide access to historical data measured by meteorological stations available in the Meteorological Database for Education and Research ([BDMEP](http://www.inmet.gov.br/projetos/rede/pesquisa/)) from National Institute of Meteorology (Instituto Nacional de Meteorologia - [INMET](http://www.inmet.gov.br)), Brazil.

Installation
------------

Installation of `inmetr` from GitHub is easy using the `devtools` package.

``` r
library(devtools)
```

``` r
install_github('jdtatsch/inmetr')
```

Load package

``` r
library(inmetr)
```

Stations ID
-----------

To search for some meteorological station from INMET we can use the `bdmep_stations()` function.

``` r
info <- bdmep_stations()
```

``` r
head(info)
```

               name state    id
    1        ACARAU    CE 82294
    2   AGUA BRANCA    AL 82989
    3       AIMORES    MG 83595
    4    ALAGOINHAS    BA 83249
    5      ALTAMIRA    PA 82353
    6 ALTO PARNAIBA    MA 82970

This function return a data frame with station names, the brazilian state and OMM code. OMM code is a necessary argument to `import_data()` function. This function download and tidy data from a meteorological station.

Here, we show how to find the [OMM code](http://www.wmo.int/pages/prog/www/ois/volume-a/StationIDs_Global_1509.pdf) for the meterological station at Santa Maria in Rio Grande do Sul state.

``` r
code <- subset(info, name == "SANTA MARIA")
code <- subset(code, select = id)[[1]]
code
```

    [1] 83936

Import data
-----------

Now we can get the data for Santa Maria city, from 1961 to the current day.

``` r
start_date <- "01/01/1961"
end_date <- format(Sys.Date(), "%d/%m/%Y")
sm <- import_bdmep(id = code,
                   sdate = start_date, 
                   edate = end_date, 
                   email = "your-email",
                   passwd = "your-password")
```

    Login sucessfull.

``` r
# check de start date
head(sm)
```

                     date    id prec tair   tw tmax tmin urmax  patm pnmm wd
    1 1961-01-01 00:00:00 83936   NA   NA   NA 31.9   NA    NA    NA   NA NA
    2 1961-01-01 12:00:00 83936   NA 23.9 21.4   NA 18.1    79 990.3   NA NA
    3 1961-01-01 18:00:00 83936   NA 30.6 25.1   NA   NA    63 988.2   NA NA
    4 1961-01-02 00:00:00 83936   NA 27.7 24.4 34.0   NA    75 986.4   NA NA
    5 1961-01-02 12:00:00 83936    0 26.4 23.8   NA 23.5    79 989.4   NA NA
    6 1961-01-02 18:00:00 83936   NA 30.8 25.2   NA   NA    62 989.0   NA NA
      wsmax   n cc evap    ur       ws
    1    NA 7.7 NA  1.1 73.00 1.000000
    2     0  NA  0   NA    NA       NA
    3     3  NA  9   NA    NA       NA
    4     0 6.0  0  2.7 74.25 0.666667
    5     0  NA  4   NA    NA       NA
    6     1  NA 10   NA    NA       NA

``` r
# check de end date
tail(sm)
```

                         date    id prec tair tw tmax tmin urmax   patm   pnmm
    52316 2016-07-09 12:00:00 83936 12.8 11.4 NA   NA 11.4   100 1007.0 1019.6
    52317 2016-07-09 18:00:00 83936   NA 13.8 NA   NA   NA    84 1001.8 1014.3
    52318 2016-07-10 00:00:00 83936   NA 12.0 NA 14.6   NA    98 1002.8 1015.4
    52319 2016-07-10 12:00:00 83936  6.3 11.0 NA   NA  9.6   100 1003.1 1015.7
    52320 2016-07-10 18:00:00 83936   NA 14.4 NA   NA   NA    94 1000.2 1012.7
    52321 2016-07-11 00:00:00 83936   NA 14.0 NA   NA   NA    95 1000.3 1012.8
          wd   wsmax  n   cc evap ur      ws
    52316 14 1.54332 NA 10.0   NA NA      NA
    52317 14 1.02888 NA 10.0   NA NA      NA
    52318 14 1.54332  0  0.0   NA 96 1.37184
    52319 14 0.51444 NA   NA   NA NA      NA
    52320 14 2.05776 NA 10.0   NA NA      NA
    52321 14 1.54332 NA  7.5   NA NA      NA

A description about the meteorological variables can be obtained with `data_description()`.

``` r
data_description()
```

       varname                         description  unit
    1     date           date and time information     -
    2       id                          station ID     -
    3     prec                       precipitation    mm
    4     tair                     air temperature deg C
    5       tw                wet bulb temperature deg C
    6     tmax             maximum air temperature deg C
    7     tmin             minimum air temperature deg C
    8    urmax           maximum relative humidity     %
    9     patm                atmospheric pressure   hPa
    10    pnmm mean sea level atmospheric pressure   hPa
    11      wd                      wind direction   deg
    12   wsmax                           wind gust   m/s
    13       n                      sunshine hours     h
    14      cc                         cloud cover     -
    15    evap                         evaporation    mm
    16      ur                   relative humidity     %
    17      ws                          wind speed   m/s

To download and write data from multiple stations to files, we can do a looping in stations id.

``` r
# first 3 stations of info table
nstns <- 3
stns_ids <- info$id[1:nstns] 
stns_ids
```

    ## [1] 82294 82989 83595

``` r
# looping on stations id
stn_files <- sapply(stns_ids,
                    function(i){
                      # i = 82294  
                      Sys.sleep(sample(5:15, 1))
                      x <- import_bdmep(id = i,
                                        sdate = "01/01/1961", 
                                        edate = "29/08/2016", 
                                        email = "your-email",
                                        passwd = "your-password")
                      # write data to a csv file (named "id.csv") in the work directory 
                      ofname <- paste0(i, ".csv")
                      write.csv(x, file = ofname)
                      # check if files were downloaded
                      if(file.exists(ofname)){
                        out <- ofname
                      } else {
                        out <- "NA"
                      }# end if
                      return(out)
                    }# end function
)# end sapply
```

    ## Login sucessfull.
    ## Login sucessfull.
    ## Login sucessfull.

``` r
stn_files
```

    ## [1] "82294.csv" "82989.csv" "83595.csv"

To cite this software
---------------------

``` r
citation("inmetr")
```


    To cite package 'inmetr' in publications use:

      Tatsch, J.D. 2016. inmetr: A Package to Import Historical Data
      from Brazilian Meteorological Stations. Zenodo,
      doi:10.5281/zenodo.59652.

    A BibTeX entry for LaTeX users is

      @Manual{,
        title = {inmetr: A Package to Import Historical Data from Brazilian Meteorological
    Stations},
        author = {Jonatan Tatsch},
        year = {2016},
        note = {R package version 0.0.1},
        doi = {http://doi.org/10.5281/ZENODO.59652 },
        institution = {Universidade Federal de Santa Maria-UFSM},
        url = {https://github.com/jdtatsch/inmetr},
        address = {Santa Maria-RS, Brazil},
      }
