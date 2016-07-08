# inmetr
Jonatan Tatsch  
July 8, 2016  



Funções para importar dados medidos pelas estações meteorológicas convencionais do Instituto Nacional de Meteorologia (INMET), Brasil.

> Em construção.

# Pré-requisitos


```r
library(httr)
library(xml2)
library(rvest)
library(plyr)
library(dplyr)
library(magrittr)
library(purrr)
library(stringr)
library(doBy)
library(devtools)
```

# Funções para download e leitura dos dados do [BDMEP](http://www.inmet.gov.br/projetos/rede/pesquisa/)

Carregando script do github.


```r
#source_url('https://raw.githubusercontent.com/jdtatsch/inmetr/master/R/bdmep.R')
source("R/bdmep.R")
ls()
```

```
[1] "bdmep_info"     "get_meta_bdmep" "import_bdmep"   "read_bdmep"    
```

# Exemplo

Obtendo códigos das estações meteorológicas.


```r
info <- bdmep_info()
info
```

```
## # A tibble: 265 x 3
##             nome estado codigo_omm
## *          <chr>  <chr>      <int>
## 1         ACARAU     CE      82294
## 2    AGUA BRANCA     AL      82989
## 3        AIMORES     MG      83595
## 4     ALAGOINHAS     BA      83249
## 5       ALTAMIRA     PA      82353
## 6  ALTO PARNAIBA     MA      82970
## 7          APODI     RN      82590
## 8        ARACAJU     SE      83096
## 9        ARACUAI     MG      83442
## 10     ARAGARCAS     GO      83368
## # ... with 255 more rows
```

Obtendo o código da estação de Santa Maria-RS.


```r
# código de Santa Maria
codigo <- info %>% 
  filter(nome == "SANTA MARIA") %>%
  select(codigo_omm) %>%
  t() %>% c()
codigo
```

```
[1] 83936
```

Importando dados.



```r
# apenas importa os dados
data_sm <- import_bdmep(stn_id = codigo, 
                        e_mail = "seu-email",
                        passwd = "sua-senha",
                        save_file = FALSE, 
                        import = TRUE)
data_sm
```


```
Login sucessfull.
```

```
# A tibble: 52,115 x 18
                  date  site  prec   tar    tw  tmax  tmin   urx  patm
                <time> <int> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
1  1961-01-01 00:00:00 83936    NA    NA    NA  31.9    NA    NA    NA
2  1961-01-01 12:00:00 83936    NA  23.9  21.4    NA  18.1    79 990.3
3  1961-01-01 18:00:00 83936    NA  30.6  25.1    NA    NA    63 988.2
4  1961-01-02 00:00:00 83936    NA  27.7  24.4  34.0    NA    75 986.4
5  1961-01-02 12:00:00 83936     0  26.4  23.8    NA  23.5    79 989.4
6  1961-01-02 18:00:00 83936    NA  30.8  25.2    NA    NA    62 989.0
7  1961-01-03 00:00:00 83936    NA  27.6  24.6  31.6    NA    78 988.2
8  1961-01-03 12:00:00 83936     0  23.3  19.9    NA  20.1    72 991.1
9  1961-01-03 18:00:00 83936    NA  31.2  23.6    NA    NA    51 990.3
10 1961-01-04 00:00:00 83936    NA  22.9  19.4  31.4    NA    71 991.2
# ... with 52,105 more rows, and 9 more variables: pnmm <dbl>, wd <dbl>,
#   wsx <dbl>, n <dbl>, cc <dbl>, evap <dbl>, tcomp <dbl>, ur <dbl>,
#   ws <dbl>
```

