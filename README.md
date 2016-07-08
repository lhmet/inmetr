# inmetr
Jonatan Tatsch  
July 8, 2016  



Funções para importar dados medidos pelas estações meteorológicas convencionais do Instituto Nacional de Meteorologia (INMET), Brasil.

> AVISO: em construção.

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
library(tibble)
```

# Funções para download e leitura dos dados do [BDMEP](http://www.inmet.gov.br/projetos/rede/pesquisa/)

Carregando script do github.


```r
source_url('https://raw.githubusercontent.com/jdtatsch/inmetr/master/R/bdmep.R')
#source("R/bdmep.R")
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

## Informações da seção



```
R version 3.3.1 (2016-06-21)
Platform: x86_64-pc-linux-gnu (64-bit)
Running under: Ubuntu 14.04.4 LTS

locale:
 [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
 [3] LC_TIME=pt_BR.UTF-8        LC_COLLATE=en_US.UTF-8    
 [5] LC_MONETARY=pt_BR.UTF-8    LC_MESSAGES=en_US.UTF-8   
 [7] LC_PAPER=pt_BR.UTF-8       LC_NAME=C                 
 [9] LC_ADDRESS=C               LC_TELEPHONE=C            
[11] LC_MEASUREMENT=pt_BR.UTF-8 LC_IDENTIFICATION=C       

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] tibble_1.1      devtools_1.11.1 doBy_4.5-15     stringr_1.0.0  
 [5] purrr_0.2.1     magrittr_1.5    dplyr_0.5.0     plyr_1.8.4     
 [9] rvest_0.3.1     xml2_0.1.2      httr_1.2.1     

loaded via a namespace (and not attached):
 [1] Rcpp_0.12.5     knitr_1.13.1    MASS_7.3-45     lattice_0.20-33
 [5] R6_2.1.2        tools_3.3.1     grid_3.3.1      DBI_0.4-1      
 [9] selectr_0.2-3   withr_1.0.1     htmltools_0.3.5 lazyeval_0.1.10
[13] yaml_2.1.13     digest_0.6.9    assertthat_0.1  Matrix_1.2-6   
[17] tidyr_0.5.0     formatR_1.4     curl_0.9.7      memoise_1.0.0  
[21] evaluate_0.9    rmarkdown_0.9.6 stringi_1.1.1   XML_3.98-1.4   
```
