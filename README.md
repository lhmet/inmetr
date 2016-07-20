`inmetr` provide access to the "Banco de Dados Meteorológicos para
Ensino e Pesquisa"
([BDMEP](http://www.inmet.gov.br/projetos/rede/pesquisa/)) from the
Instituto Nacional de Meteorologia ([INMET](http://www.inmet.gov.br)),
Brazil.

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

This function will return station names, the brazilian state and OMM
code. OMM code is necessary to download data from a meteorological
station.

Here we want to know the [OMM
code](http://www.wmo.int/pages/prog/www/ois/volume-a/StationIDs_Global_1509.pdf)
for the meterological station at Santa Maria in Rio Grande do Sul state.

    code <- filter(info, name == "SANTA MARIA") 
    code <- select(code, id)[[1]]
    code

    [1] 83936

Import data
-----------

Now we can get the data for Santa Maria city with the function
`import_bdmep()`.

    sm <- import_bdmep(id = code, 
                       email = "seu-email",
                       passwd = "sua-senha")

    Login sucessfull.

    head(sm)


    ------------------------------------------------------------------------------
           date          site   prec   tar   tw   tmax   tmin   urx   patm   pnmm 
    ------------------- ------ ------ ----- ---- ------ ------ ----- ------ ------
        1961-01-01      83936    NA    NA    NA   31.9    NA    NA     NA     NA  

    1961-01-01 12:00:00 83936    NA   23.9  21.4   NA    18.1   79   990.3    NA  

    1961-01-01 18:00:00 83936    NA   30.6  25.1   NA     NA    63   988.2    NA  

        1961-01-02      83936    NA   27.7  24.4   34     NA    75   986.4    NA  

    1961-01-02 12:00:00 83936    0    26.4  23.8   NA    23.5   79   989.4    NA  

    1961-01-02 18:00:00 83936    NA   30.8  25.2   NA     NA    62    989     NA  
    ------------------------------------------------------------------------------

    Table: Table continues below

     
    -----------------------------------------------
     wd   wsx   n   cc   evap   tcomp   ur     ws  
    ---- ----- --- ---- ------ ------- ----- ------
     NA   NA   7.7  NA   1.1    25.86   73     1   

     NA    0   NA   0     NA     NA     NA     NA  

     NA    3   NA   9     NA     NA     NA     NA  

     NA    0    6   0    2.7    27.82  74.25 0.6667

     NA    0   NA   4     NA     NA     NA     NA  

     NA    1   NA   10    NA     NA     NA     NA  
    -----------------------------------------------
