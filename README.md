inmetr
================

inmetr: A R-package to Import Historical Data from Brazilian Meteorological Stations
====================================================================================

[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.59652.svg)](http://dx.doi.org/10.5281/zenodo.59652) [![Version](https://img.shields.io/badge/Version-0.0.2-orange.svg)](https://img.shields.io/badge/Version-0.0.2-orange.svg)

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
met_data <- import_bdmep(id = code,
                         sdate = start_date, 
                         edate = end_date, 
                         email = "your-email",
                         passwd = "your-password",
                         verbose = TRUE)
```

    Login sucessfull.

``` r
# check de start date
head(met_data)
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
tail(met_data)
```

                         date    id prec tair tw tmax tmin urmax  patm   pnmm
    52837 2016-12-30 00:00:00 83936   NA 24.0 NA 33.4   NA    95 998.4 1010.4
    52838 2016-12-30 12:00:00 83936 10.2 24.6 NA   NA 22.8    93 999.6 1011.6
    52839 2016-12-30 18:00:00 83936   NA 31.6 NA   NA   NA    71 995.9 1007.7
    52840 2016-12-31 00:00:00 83936   NA 25.2 NA 31.4   NA    90 996.8 1008.7
    52841 2016-12-31 12:00:00 83936  2.1 26.4 NA   NA 24.2    78 997.9 1009.8
    52842 2016-12-31 18:00:00 83936   NA 29.8 NA   NA   NA    70 995.2 1007.0
          wd   wsmax   n    cc evap ur      ws
    52837 14 2.05776 7.4  7.50   NA 86 2.22924
    52838 14 1.54332  NA  8.75   NA NA      NA
    52839 18 3.08664  NA  7.50   NA NA      NA
    52840 14 2.05776 5.5 10.00   NA 74 3.08664
    52841 36 2.57220  NA 10.00   NA NA      NA
    52842 36 2.57220  NA  7.50   NA NA      NA

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
stations <- c("SAO PAULO", "RIO DE JANEIRO", "PORTO ALEGRE")
stations_rows <- pmatch(stations, info$name)
info[stations_rows, ]
```

    ##                          name state    id
    ## 233 SAO PAULO(MIR.de SANTANA)    SP 83781
    ## 212            RIO DE JANEIRO    RJ 83743
    ## 199              PORTO ALEGRE    RS 83967

``` r
stns_ids <- info[stations_rows, "id"] 
stns_ids
```

    ## [1] 83781 83743 83967

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
                                        passwd = "your-password",
                                        verbose = FALSE)
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
stn_files
```

    ## [1] "83781.csv" "83743.csv" "83967.csv"

To cite this software
---------------------

``` r
citation("inmetr")
```


    To cite package 'inmetr' in publications use:

      Tatsch, J.D. 2017. inmetr: A Package to Import Historical Data
      from Brazilian Meteorological Stations. Zenodo,
      doi:10.5281/zenodo.59652.

    A BibTeX entry for LaTeX users is

      @Manual{,
        title = {inmetr: A Package to Import Historical Data from Brazilian Meteorological
    Stations},
        author = {Jonatan Tatsch},
        year = {2017},
        note = {R package version 0.0.2},
        doi = {http://doi.org/10.5281/ZENODO.59652 },
        institution = {Universidade Federal de Santa Maria-UFSM},
        url = {https://github.com/jdtatsch/inmetr},
        address = {Santa Maria-RS, Brazil},
      }
