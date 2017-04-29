utils::globalVariables(c(".", "data", "hora", "codigo", "nome_estacao", "prec", "site", "ws", "tcomp", "id"))

##' Read data downaloaded from BDMEP
##' 
##' Read and tidy data downloaded with \code{\link{import_bdmep}}
##' 
##' @importFrom utils read.csv2 head
##' 
##' @details A minimum quality control check is applied to the data
##' This include: a chronological sequence check; filling missing dates with NA; 
##' remove duplicated data; aggregate time and date information into a POSIX object
##' 
##' @param x a numeric vector with the meteorological station code
##' 
##' @return a data frame with variables in columns and observations along rows
##' @author Jonatan Tatsch
##' 
read_bdmep <- function(x){
  
  # find line with variables names
  rowheader <- x %>%
    # toUTF8()
    stringr::str_detect("Data;Hora;") %>%
    which() 
  # variable names
  h <- x[rowheader]
  
  # extract header and fix it
  h_fix <- h %>%
    stringr::str_replace("VelocidadeVentoInsolacao;", "VelocidadeVento;Insolacao;") %>%
    stringr::str_split(";") %>%
    unlist() 
  
  to_discard <- h_fix %>%
    magrittr::equals("") %>%
    which() %>%
    prod(-1)
  
  h_fix <- h_fix[to_discard]
  
  ## replace original vnames by the new ones
  new_vnames <- c("codigo", "data","hora",
                  "prec", "tair", "tw", "tmax", "tmin", "urmax", 
                  "patm", "pnmm", "wd", "wsmax", "n", "cc", "evap", "tcomp", "ur", "ws")
  vnames <-  doBy::recodeVar(as.character(h_fix),
                             src = as.list(as.character(h_fix)), 
                             tgt = as.list(new_vnames))
  
  x_clean <- x %>% 
    magrittr::extract((rowheader+1) : (length(x)-1)) %>%
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
  sel_vars <- names(bdmepd)[!names(bdmepd) %in% c("codigo","data", "hora")]
  bdmepd <- bdmepd %>%
    dplyr::mutate_each_(dplyr::funs(as.numeric), sel_vars)
  
  ## date conversion
  bdmepd <- bdmepd %>%
    dplyr::mutate(hora = doBy::recodeVar(as.character(hora),
                                  src = as.list(c("1800","0","1200")), 
                                  tgt = as.list(c("18:00","00:00","12:00"))),
           date = as.POSIXct(paste(as.Date(data,
                                           format="%d/%m/%Y"),
                                   hora,
                                   sep = " "), 
                             tz = "UTC"),
           data = NULL,
           hora = NULL,
           id = codigo,
           codigo = NULL) 
  # reorder columns
  bdmepd <- bdmepd %>% 
    dplyr::select(date, id, prec:ws, -tcomp)
  
  # duplicated rows
    bdmepd <- dplyr::distinct(bdmepd)

    return(bdmepd)
  
}## end function readInmet




##' Import data from Brazilian meteorological stations
##' Import historical data from Brazilian meteorological stations available in the Meteorological Database for Education and Research \href{http://www.inmet.gov.br/projetos/rede/pesquisa}{BDMEP} of National Institute of Meteorology \href{http://www.inmet.gov.br}{INMET}
##' 
##' @importFrom stats setNames
##' @importFrom dplyr %>%
##' @details The data are in sub-daily time scale. A minimum data quality control is applied to the data.
##' This include: a chronological sequence check; filling data from missing dates with NA; 
##' remove duplicated data. Time variables (year, month, day, hour) are aggregated into a POSIX object in UTC
##' 
##' @param id a numeric vector with the meteorological station code
##' @param sdate start date in "d/m/Y" format
##' @param edate end date in "d/m/Y" format, default values \code{format(Sys.Date(), "\%d/\%m/\%Y")}
##' @param email e-mail to access BDMEP 
##' @param passwd password to access BDMEP
##' @param verbose if TRUE, prints login sucessfull; if not, not. Default is TRUE.
##' 
##' @return a data frame with variables in columns and observations along rows
##' @export
##' @author Jonatan Tatsch
##' @examples 
##' # download data for Santa Maria-RS 
##' sm <- import_bdmep(id = 83936, email = "your-email", passwd = "your-password", verbose = TRUE)
##' head(sm)
##' summary(sm)
##' 
import_bdmep <- function(id = "83586" ,
                         sdate = "01/01/1961",
                         edate = format(Sys.Date(), '%d/%m/%Y'),
                         email = "your-email",
                         passwd = "your-password",
                         verbose = TRUE){
  
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
  # add email and passwd
  l <- l %>% purrr::update_list(mCod = email, mSenha = passwd)
  # r <- httr::POST(link, body = l, encode = "form", verbose())
  r <- httr::POST(link, body = l, encode = "form")
  if(httr::status_code(r) == 200 & verbose) message("Login sucessfull.")
  # visualize(r)
  gc()
  
  # step 2 - get data
  url_data <- "http://www.inmet.gov.br/projetos/rede/pesquisa/gera_serie_txt.php?&mRelEstacao=XXXXX&btnProcesso=serie&mRelDtInicio=dd/mm/yyyy&mRelDtFim=DD/MM/YYYY&mAtributos=1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
  url_data <-  url_data %>%
    stringr::str_replace("XXXXX", as.character(id)) %>%
    stringr::str_replace("dd/mm/yyyy", sdate) %>%
    stringr::str_replace("DD/MM/YYYY", edate) 
  # raw data  
  x <- httr::GET(url_data) %>%
    httr::content('text') %>%
    textConnection(local = TRUE) %>%
    readLines()
  #closeAllConnections()

  # output
  xtidy <- read_bdmep(x)
  return(xtidy)
}

##' Get metadata on meteorological stations
##'
##' This function is used to fetch the coordinates on meteorological stations from INMET
##' \url{http://www.inmet.gov.br/projetos/rede/pesquisa/lista_estacao.php}
##' 
##' @importFrom dplyr %>%
##' @return A data frame is returned with metadata, including the stations
##'  \code{id}, and coordinates (\code{lon}, \code{lat}, \code{alt})
##' @export
##' @author Jonatan Tatsch
##' @examples 
##' 
##' info <- bdmep_metadata()
##' head(info)

bdmep_metadata <- function(){
  # omm id, lat, lon, alt
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
    #stringr::str_subset("C.*digo OMM") %>%
    stringi::stri_trans_general("latin-ascii") %>%
    stringr::str_subset("Codigo OMM") %>%
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
    setNames(c("id", "lat", "lon", "alt")) %>%
    dplyr::select_("id", "lon", "lat", "alt")
  
  rm(txt1)
  
  tab_info %>%
    data.frame() %>%
    return()
  
} # end function get_meta_bdmep


##' Get basic information on meteorological station from INMET
##'
##' This function is used to find the OMM station ID that can be
##' used to import BDMEP data using \code{\link{import_bdmep}}
##' @description Get OMM code, state and station name on meteorological stations from INMET
##' \url{http://www.inmet.gov.br/projetos/rede/pesquisa/lista_estacao.php}
##' @importFrom dplyr %>%
##' @return a data frame is returned with 
##'  \code{name}, \code{state}, \code{id}
##' @export
##' @author Jonatan Tatsch
##' @examples 
##' 
##' \dontrun{
##' # tyr get information from inmet web site
##' stns <- bdmep_stations()
##' head(stns, 15)
##' #save(stns, file = "data/stns.rda")
##' }
bdmep_stations <- function(){
  link_stns_l <- "http://www.inmet.gov.br/projetos/rede/pesquisa/lista_estacao.php"
  tab <- httr::GET(link_stns_l) %>%
    httr::content('text') %>%
    xml2::read_html() %>%
    rvest::html_node("table") %>%
    rvest::html_table(header = TRUE)
  
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
    #iconv(to='ASCII//TRANSLIT') %>%
    stringi::stri_trans_general("latin-ascii") %>%
    stringr::str_replace_all(" ", "_") %>%
    stringr::str_replace("_da", "") %>%
    setNames(tab, nm = .) %>%
    tidyr::separate(nome_estacao, c("nome", "estado"), sep = " - ")
  tab %>% 
    data.frame() %>%
    setNames(c("name", "state", "id")) %>%
    return()
}


##' Meteorological variables description
##'
##' This function describe the Meteorological variables imported with \code{\link{import_bdmep}}
##' @description Get variable names, description and units
##' @importFrom dplyr %>%
##' @details to information about instruments see \url{http://www.inmet.gov.br/portal/index.php?r=home/page&page=instrumentos}
##' @return a data frame is returned with 
##'  \code{varname}, \code{description}, \code{unit}
##' @export
##' @author Jonatan Tatsch
##' @examples 
##' met_vars <- data_description()
##' met_vars
##' 
data_description<- function() {
  data.frame(varname     = c("date", 
                             "id", 
                             "prec",  
                             "tair", 
                             "tw", 
                             "tmax", 
                             "tmin",  
                             "urmax", 
                             "patm", 
                             "pnmm",  
                              "wd",  
                             "wsmax",    
                             "n",   
                             "cc", 
                             "evap", 
                             "ur",   
                             "ws"),
             description = c("date and time information",
                             "station ID",
                             "precipitation",
                             "air temperature",
                             "wet bulb temperature",
                             "maximum air temperature",
                             "minimum air temperature",
                             "maximum relative humidity",
                             "atmospheric pressure",
                             "mean sea level atmospheric pressure",
                             "wind direction",
                             "wind gust",
                             "sunshine hours",
                             "cloud cover",
                             "evaporation",
                             "relative humidity",
                             "wind speed"
                             ),
             unit        = c("-",
                             "-",
                             "mm",
                             "deg C",
                             "deg C",
                             "deg C",
                             "deg C",
                             "%",
                             "hPa",
                             "hPa",
                             "deg",
                             "m/s",
                             "h",
                             "-",
                             "mm",
                             "%",
                             "m/s"
                             ))
}
