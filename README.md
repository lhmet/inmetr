# inmetr



`inmetr` provide access to the "Banco de Dados Meteorológicos para Ensino e Pesquisa" ([BDMEP](http://www.inmet.gov.br/projetos/rede/pesquisa/)) do Instituto Nacional de Meteorologia ([INMET](http://www.inmet.gov.br)), Brazil.



## Instalation

Installation of inmetr from GitHub is easy using the devtools package.


```r
library(devtools)
install_github('jdtatsch/inmetr')
```


```r
library(inmetr)
library(dplyr)
```

## Station metadata

To search for meteorological station from INMET the user can use the `bdmep_info()` function.


```r
info <- bdmep_info()
#head(info)
str(info)
```

```
'data.frame':	265 obs. of  3 variables:
 $ nome      : chr  "ACARAU" "AGUA BRANCA" "AIMORES" "ALAGOINHAS" ...
 $ estado    : chr  "CE" "AL" "MG" "BA" ...
 $ codigo_omm: int  82294 82989 83595 83249 82353 82970 82590 83096 83442 83368 ...
```

This function will return all site names, state and OMM code. The OMM code is necessary to download data from a meteorological station.

Here we want to know the [OMM code](http://www.wmo.int/pages/prog/www/ois/volume-a/StationIDs_Global_1509.pdf) for the meterological station at Santa Maria in Rio Grande do Sul state.


```r
code <- info %>% 
   filter(nome == "SANTA MARIA") %>%
   select(codigo_omm) %>%
   t() %>% c()
code
```

```
[1] 83936
```

## Import data


```r
sm <- import_bdmep(stn_id = code, 
                   e_mail = "seu-email",
                   passwd = "sua-senha",
                   save_file = FALSE, 
                   import = TRUE)
#head(sm)
str(sm)
```



```
## Login sucessfull.
```

```
## 'data.frame':	52321 obs. of  18 variables:
##  $ date : POSIXct, format: "1961-01-01 00:00:00" "1961-01-01 12:00:00" ...
##  $ site : int  83936 83936 83936 83936 83936 83936 83936 83936 83936 83936 ...
##  $ prec : num  NA NA NA NA 0 NA NA 0 NA NA ...
##  $ tar  : num  NA 23.9 30.6 27.7 26.4 30.8 27.6 23.3 31.2 22.9 ...
##  $ tw   : num  NA 21.4 25.1 24.4 23.8 25.2 24.6 19.9 23.6 19.4 ...
##  $ tmax : num  31.9 NA NA 34 NA NA 31.6 NA NA 31.4 ...
##  $ tmin : num  NA 18.1 NA NA 23.5 NA NA 20.1 NA NA ...
##  $ urx  : num  NA 79 63 75 79 62 78 72 51 71 ...
##  $ patm : num  NA 990 988 986 989 ...
##  $ pnmm : num  NA NA NA NA NA NA NA NA NA NA ...
##  $ wd   : num  NA NA NA NA NA NA NA NA NA NA ...
##  $ wsx  : num  NA 0 3 0 0 1 1 3 5 7 ...
##  $ n    : num  7.7 NA NA 6 NA NA 7.8 NA NA 9.2 ...
##  $ cc   : num  NA 0 9 0 4 10 0 8 10 10 ...
##  $ evap : num  1.1 NA NA 2.7 NA NA 2.6 NA NA 3.2 ...
##  $ tcomp: num  25.9 NA NA 27.8 NA ...
##  $ ur   : num  73 NA NA 74.2 NA ...
##  $ ws   : num  1 NA NA 0.667 NA ...
```


