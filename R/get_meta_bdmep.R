library(httr)
library(stringr)

library(xml2)
library(rvest)
library(plyr)
library(dplyr)
library(magrittr)
library(purrr)

library(doBy)

##' Get information on conventional meteorological station from INMET
##'
##' This function is used to find the OMM code that can be
##' used to import BDMEP data using \code{\link{import_bdmep}}.
##' @title Get OMM code and other meta data on meteorological stations from INMET
##' @param none
##' \url{http://www.inmet.gov.br/projetos/rede/pesquisa/lista_estacao.php}.
##' @return A data frame is returned with meta data, including a
##'  \code{site} that can be supplied to
##' \code{\link{import_bdmep}}, coordinates \code{lon}, \code{lat}, and
##'  \code{alt}.
##' @export
##' @author Jônatan Tatsch
##' @examples 
##' 
##' \dontrun{
##' # this can take a while
##' metad <- get_meta_bdmep()
##' head(metad, 15)
##' #save(metad, file = "data/metad.rda")
##' # plot locations
##' with(metad, plot(lon, lat, pch = 4))
##' }

get_meta_bdmep <- function(){
  require(dplyr)
  # omm_code, lat, lon, alt
  link_stns_info <- "http://www.inmet.gov.br/sim/sonabra/index.php"
  #link_stns_info <- "http://www.inmet.gov.br/portal/index.php?r=estacoes/mapaEstacoes"
  txt <- httr::GET(link_stns_info) %>%
    httr::content('text') %>% 
    textConnection() %>%
    readLines() 
  
  closeAllConnections()
  rm(link_stns_info)
  
  txt1 <- 
    txt %>%
    stringr::str_subset("Código OMM") %>%
    stringr::str_extract_all("[-+]?([0-9]*\\.[0-9]+|[0-9]+)")
  
  rm(txt)
  
  tab_info <- 
    txt1 %>%
    plyr::ldply(function(x){
      #x <- a
      n <- length(x)
      x[c(3, n - (2:0))] %>%
        as.numeric() %>%
        return()
    }) %>%
    setNames(c("site", "lat", "lon", "alt")) %>%
    tbl_df() %>%
    dplyr::select(site, lon, lat, alt)
  
  rm(txt1)
  
  return(tab_info)
  
} # end function get_meta_bdmep



##' Get basic information on meteorological station from INMET
##'
##' This function is used to find the OMM code that can be
##' used to import BDMEP data using \code{\link{import_bdmep}}.
##' @title Get OMM code, state and station name on meteorological stations from INMET
##' @param none
##' \url{http://www.inmet.gov.br/projetos/rede/pesquisa/lista_estacao.php}.
##' @return A data frame is returned with 
##'  \code{nome}, \code{estado}, \code{codigo_omm}
##' @export
##' @author Jônatan Tatsch
##' @examples 
##' 
##' \dontrun{
##' # this can take a while
##' metad <- get_meta_bdmep()
##' head(metad, 15)
##' #save(metad, file = "data/metad.rda")
##' # plot locations
##' with(metad, plot(lon, lat, pch = 4))
##' }

bdmep_info <- function(){
  link_stns_l <- "http://www.inmet.gov.br/projetos/rede/pesquisa/lista_estacao.php"
  tab <- httr::GET(link_stns_l) %>%
    httr::content('text') %>%
    xml2::read_html() %>%
    rvest::html_node("table") %>%
    rvest::html_table(header = TRUE) %>%
    dplyr::tbl_df()
  
  is_space <- function(x) x == ""
  
  # remove colum named " "
  tab <- tab %>%
    names() %>%
    stringr::str_trim() %>%
    purrr::discard(is_space) %>%
    subset(tab, sel = .)
  
  tab <- tab %>%
    names() %>%
    tolower() %>%
    # replace accented characters with non-accented counterpart
    # (UTF-8 encoding)
    iconv(to='ASCII//TRANSLIT') %>%
    stringr::str_replace_all(" ", "_") %>%
    stringr::str_replace("_da", "") %>%
    setNames(tab, nm = .) %>%
    tidyr::separate(nome_estacao, c("nome", "estado"), sep = " - ")
  return(tab)
}
