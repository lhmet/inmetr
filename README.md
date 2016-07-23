Overview
--------

`inmetr` provide access to historical data measured by meteorological
stations available in the Meteorological Database for Education and
Research ([BDMEP](http://www.inmet.gov.br/projetos/rede/pesquisa/)) from
National Institute of Meteorology (Instituto Nacional de Meteorologia -
[INMET](http://www.inmet.gov.br)), Brazil.

Instalation
-----------

Installation of `inmetr` from GitHub is easy using the `devtools`
package.

    library(devtools)
    install_github('jdtatsch/inmetr')

    library(inmetr)
    library(dplyr)

Stations ID
-----------

To search for meteorological station from INMET we can use the
`bdmep_stations()`.

    info <- bdmep_stations()

    head(info)


    ---------------------------
        name       state   id  
    ------------- ------- -----
       ACARAU       CE    82294

     AGUA BRANCA    AL    82989

       AIMORES      MG    83595

     ALAGOINHAS     BA    83249

      ALTAMIRA      PA    82353

    ALTO PARNAIBA   MA    82970
    ---------------------------

This function will return a data frame with station names, the brazilian
state and OMM code. OMM code is necessary to download data from a
meteorological station with `import_data()`.

Here we want to know the [OMM
code](http://www.wmo.int/pages/prog/www/ois/volume-a/StationIDs_Global_1509.pdf)
for the meterological station at Santa Maria in Rio Grande do Sul state.

    code <- filter(info, name == "SANTA MARIA")
    code <- select(code, id)[[1]]
    code

    [1] 83936

Import data
-----------

Now we can get the data for Santa Maria city, from 1961 to current day.
These are default values for `sdate`(start date) and `edate` (end date)
arguments of function `import_bdmep()`.

    sm <- import_bdmep(id = code, 
                       email = "your-email",
                       passwd = "your-password")
    # default values
    args(import_bdmep)

    Login sucessfull.

    function (id = "83586", sdate = "01/01/1961", edate = format(Sys.Date(), 
        "%d/%m/%Y"), email = "your-email", passwd = "your-password") 
    NULL

    head(sm)


    -----------------------------------------------------------------------------
           date          id    prec   tar   tw   tmax   tmin   urx   patm   pnmm 
    ------------------- ----- ------ ----- ---- ------ ------ ----- ------ ------
        1961-01-01      83936   NA    NA    NA   31.9    NA    NA     NA     NA  

    1961-01-01 12:00:00 83936   NA   23.9  21.4   NA    18.1   79   990.3    NA  

    1961-01-01 18:00:00 83936   NA   30.6  25.1   NA     NA    63   988.2    NA  

        1961-01-02      83936   NA   27.7  24.4   34     NA    75   986.4    NA  

    1961-01-02 12:00:00 83936   0    26.4  23.8   NA    23.5   79   989.4    NA  

    1961-01-02 18:00:00 83936   NA   30.8  25.2   NA     NA    62    989     NA  
    -----------------------------------------------------------------------------

    Table: Table continues below

     
    ---------------------------------------
     wd   wsx   n   cc   evap   ur     ws  
    ---- ----- --- ---- ------ ----- ------
     NA   NA   7.7  NA   1.1    73     1   

     NA    0   NA   0     NA    NA     NA  

     NA    3   NA   9     NA    NA     NA  

     NA    0    6   0    2.7   74.25 0.6667

     NA    0   NA   4     NA    NA     NA  

     NA    1   NA   10    NA    NA     NA  
    ---------------------------------------

A description about the meteorological variables can be obtained with
`data_description()`.

    (met_vars <- data_description())

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
