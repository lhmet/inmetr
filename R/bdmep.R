library(httr)
library(xml2)
library(rvest)
library(plyr)
library(dplyr)
library(magrittr)
library(purrr)
library(stringr)
library(doBy)


#####################################################################  
## read_bdmep - tidy data from import_bdmep()
#####################################################################
read_bdmep <- function(x, dup.first = T)
{
  
  # line with variables names
  rowheader <- x %>%
    # toUTF8()
    stringr::str_detect("Data;Hora;") %>%
    which() 
  # variable names
  h <- rowheader %>%
    `[`(x, .)
  
  ## extract header and fix it
  h_fix <- h %>%
    stringr::str_replace("VelocidadeVentoInsolacao;", "VelocidadeVento;Insolacao;") %>%
    stringr::str_split(";") %>%
    unlist() 
  
  h_fix <- h_fix %>%
    `==`("") %>%
    which() %>%
    `*`(-1) %>%
    `[`(h_fix, .)
  
  ## replace original vnames by the new ones
  new_vnames <- c("codigo", "Data","Hora",
                  "prec", "tar", "tw", "tmax", "tmin", "urx", 
                  "patm", "pnmm", "wd", "wsx", "n", "cc", "evap", "tcomp", "ur", "ws")
  vnames <-  doBy::recodeVar(as.character(h_fix),
                             src = as.list(as.character(h_fix)), 
                             tgt = as.list(new_vnames))
  
  x_clean <- x %>% 
    `[`((rowheader+1) : (length(x)-1)) %>%
    stringr::str_replace(";$", "")

  bdmepd <- read.csv2(text = x_clean, 
                     header = FALSE, 
                     stringsAsFactors = FALSE,
                     na.strings = "")

  # stop if there is conflict between ncol(x) and length(hvec)
  if(ncol(bdmepd) != length(vnames)) {
    print(head(bdmepd))
    cat("ncol(x) = ", ncol(bdmepd), "\n", 
        "hvec = ", vnames, "\n", "\n")
    
    stop("num. of data columns does not match the num. of variables")
  } else {
    names(bdmepd) <- vnames
  }# end if
  
  #bdmepd_bck <- bdmepd
  
  # coercion to numeric due to na.strings = "" 
  sel_vars <- names(bdmepd)[!names(bdmepd) %in% c("codigo","Data", "Hora")]
  bdmepd <- bdmepd %>%
    dplyr::mutate_each_(funs(as.numeric), sel_vars)
  
  ## date conversion
  bdmepd <- bdmepd %>%
    mutate(Hora = doBy::recodeVar(as.character(Hora),
                                  src = as.list(c("1800","0","1200")), 
                                  tgt = as.list(c("18:00","00:00","12:00"))),
           date = as.POSIXct(paste(as.Date(Data,
                                           format="%d/%m/%Y"),
                                   Hora,
                                   sep = " "), 
                             tz = "UTC"),
           Data = NULL,
           Hora = NULL,
           site = codigo,
           codigo = NULL) %>%
    tbl_df()
  # reorder columns
  bdmepd <- bdmepd %>% 
    dplyr::select(date, site, prec:ws)
  
  # duplicated rows
  if(dup.first){
    #bdmepd <- bdmepd %>%
    #  filter(!duplicated(date))
    bdmepd <- dplyr::distinct(bdmepd)
  } else {
    bdmepd <- bdmepd %>%
      filter(!duplicated(date, fromLast = T))
  }
  
  return(bdmepd)
  
}## end function readInmet

# fetch bdmep data from inmet site
import_bdmep <- function(stn_id = "83586" ,
                         sdate = "01/01/1961",
                         edate = format(Sys.Date(), '%d/%m/%Y'),
                         e_mail = "jdtatsch@gmail.com",
                         passwd = "d17ulev5",
                         import = TRUE,
                         dest_file = paste0(stn_id, ".txt"),
                         save_file = TRUE){
  
  if(isTRUE(!save_file) && isTRUE(!import)){
    stop("Noting to do. save_file = FALSE and import = FALSE.")
  }
  
  # step 1 - login
  link <- "http://www.inmet.gov.br/projetos/rede/pesquisa/inicio.php"
  txt <- httr::GET(link)
  attrs_name_passwd_bt <- txt %>% 
    httr::content('text') %>% 
    xml2::read_html() %>% 
    rvest::html_nodes("form") %>%
    rvest::html_nodes("input") %>%
    magrittr::extract(c(3:4, 6)) %>%
    rvest::html_attr('name')
  
  vals_name_passwd_bt <- txt %>% 
    httr::content('text') %>% 
    xml2::read_html() %>% 
    rvest::html_nodes("form") %>%
    rvest::html_nodes("input") %>%
    magrittr::extract(c(3:4, 6)) %>%
    rvest::html_attr('value')
  # put values in a named list
  l <- vals_name_passwd_bt %>%
    seq_along() %>%
    lapply(function(i) vals_name_passwd_bt[i]) %>% 
    setNames(attrs_name_passwd_bt)
  # add e-mail and passwd
  l %<>% purrr::update_list(mCod = e_mail, mSenha = passwd)
  # r <- httr::POST(link, body = l, encode = "form", verbose())
  r <- httr::POST(link, body = l, encode = "form")
  if(status_code(r) == 200) cat("Login sucessfull.")
  # visualize(r)
  gc()
  
  # step 2 - get data
  url_data <- "http://www.inmet.gov.br/projetos/rede/pesquisa/gera_serie_txt.php?&mRelEstacao=XXXXX&btnProcesso=serie&mRelDtInicio=dd/mm/yyyy&mRelDtFim=DD/MM/YYYY&mAtributos=1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
  url_data %<>%
    stringr::str_replace("XXXXX", stn_id) %>%
    stringr::str_replace("dd/mm/yyyy", sdate) %>%
    stringr::str_replace("DD/MM/YYYY", edate) 
  # raw data  
  x <- httr::GET(url_data) %>%
    httr::content('text') %>%
    textConnection() %>%
    readLines()
  closeAllConnections()
  
  if(save_file) {
    writeLines(text = x, con = dest_file)
    message("Data saved in ", dest_file)
  }
  
  # output
  # tidy data
  if(import) xtidy <- read_bdmep(x)
  # return tidy data
  if(isTRUE(import) & isTRUE(save_file)){
    result <- xtidy
  }
  # return tidy data
  if(isTRUE(import) && !isTRUE(save_file)){
    result <- xtidy
  }
  # return file name
  if(isTRUE(save_file) && !isTRUE(import)){
    result <- dest_file
  }
  
  return(result)
}

# ex.:  
# head(bg <- import_bdmep(stn_id = "83980"))
  
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


  
  
  

  