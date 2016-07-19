# inmetr
Jonatan Tatsch  
July 8, 2016  



`inmetr` provide access to the Banco de Dados Meteorológicos para Ensino e Pesquisa ([BDMEP](http://www.inmet.gov.br/projetos/rede/pesquisa/)) do Instituto Nacional de Meteorologia ([INMET](http://www.inmet.gov.br)).



# Instalation

Installation of inmetr from GitHub is easy using the devtools package.


```r
library(devtools)
install_github('jdtatsch/inmetr')
```


```r
library(inmetr)
library(dplyr)
#library(tibble)
```

## Station metadata

To search for meteorological station from INMET the user can use the `bdmep_info()` function.


```r
info <- bdmep_info()
head(info)
```

<div class="kable-table">

nome            estado    codigo_omm
--------------  -------  -----------
ACARAU          CE             82294
AGUA BRANCA     AL             82989
AIMORES         MG             83595
ALAGOINHAS      BA             83249
ALTAMIRA        PA             82353
ALTO PARNAIBA   MA             82970

</div>

This function will return all site names, state and OMM code. The OMM code is necessary to download data from one meteorological station.

Here we want to know the OMM code for the meterological station at Santa Maria in Rio Grande do Sul state.


```r
 code <- info %>% 
   filter(nome == "SANTA MARIA") %>%
   select(codigo_omm) %>%
   t() %>% c()
```

## Import data


```r
sm <- import_bdmep(stn_id = code, 
                   e_mail = "seu-email",
                   passwd = "sua-senha",
                   save_file = FALSE, 
                   import = TRUE)
sm
```



```
## Login sucessfull.
```

<div class="kable-table">

date                    site   prec    tar     tw   tmax   tmin   urx    patm   pnmm   wd   wsx     n   cc   evap   tcomp      ur         ws
--------------------  ------  -----  -----  -----  -----  -----  ----  ------  -----  ---  ----  ----  ---  -----  ------  ------  ---------
1961-01-01 00:00:00    83936     NA     NA     NA   31.9     NA    NA      NA     NA   NA    NA   7.7   NA    1.1   25.86   73.00   1.000000
1961-01-01 12:00:00    83936     NA   23.9   21.4     NA   18.1    79   990.3     NA   NA     0    NA    0     NA      NA      NA         NA
1961-01-01 18:00:00    83936     NA   30.6   25.1     NA     NA    63   988.2     NA   NA     3    NA    9     NA      NA      NA         NA
1961-01-02 00:00:00    83936     NA   27.7   24.4   34.0     NA    75   986.4     NA   NA     0   6.0    0    2.7   27.82   74.25   0.666667
1961-01-02 12:00:00    83936      0   26.4   23.8     NA   23.5    79   989.4     NA   NA     0    NA    4     NA      NA      NA         NA
1961-01-02 18:00:00    83936     NA   30.8   25.2     NA     NA    62   989.0     NA   NA     1    NA   10     NA      NA      NA         NA

</div>


