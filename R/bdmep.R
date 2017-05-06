##' Read data downaloaded from BDMEP
##' 
##' Read and tidy data downloaded with \code{\link{bdmep_import}}
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
bdmep_read <- function(x){
  
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
    which() 
  
  h_fix <- h_fix[-to_discard]
  
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
    dplyr::mutate_at(sel_vars, dplyr::funs(as.numeric))
  
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
           id = as.character(codigo),
           codigo = NULL,
           request_status = "sucessfull") 
  # reorder columns
  bdmepd <- bdmepd %>% 
    dplyr::select(date, id, prec:ws, -tcomp)
  
  # duplicated rows
    bdmepd <- dplyr::distinct(bdmepd)

    return(bdmepd)
  
}## end function readInmet


#' Get login attributes form to acces BDMEP
#'
#' @param lnk url to BDMEP
#'
##' @return a named list with user name, password and text of button access
##' @author Jonatan Tatsch
##' 
bdmep_login_att <- function(lnk, email, passwd){
  txt <- httr::GET(lnk)
  attrs_name_passwd_bt <- txt %>% 
    httr::content("text") %>% 
    xml2::read_html() %>% 
    rvest::html_nodes("form") %>%
    rvest::html_nodes("input") %>%
    magrittr::extract(c(3:4, 6)) %>%
    rvest::html_attr("name")
  
  vals_name_passwd_bt <- txt %>% 
    httr::content("text") %>% 
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
  l <- purrr::update_list(l, mCod = email, mSenha = passwd)
  return(l)
}


##' Import data of a meteorological station
##' 
##' @importFrom stats setNames
##' @importFrom dplyr %>%
##' @details The data are in sub-daily time scale. A minimum data quality control is applied to the data.
##' This include: a chronological sequence check; filling data from missing dates with NA; 
##' remove duplicated data. Time variables (year, month, day, hour) are aggregated into a POSIX object in UTC
##' 
##' @param .id a numeric vector with the meteorological station code
##' @param .sdate start date in "d/m/Y" format
##' @param .edate end date in "d/m/Y" format, default values \code{format(Sys.Date(), "\%d/\%m/\%Y")}
##' @param .email e-mail to access BDMEP 
##' @param .passwd password to access BDMEP
##' @param .verbose if TRUE, prints login sucessfull; if not, not. Default is TRUE.
##' 
##' @return a data frame with variables in columns and observations along rows
##' @author Jonatan Tatsch
##' 
bdmep_import_station <- function(.id = "83967" ,
                         .sdate = "01/01/1961",
                         .edate = format(Sys.Date(), '%d/%m/%Y'),
                         .email = "your-email",
                         .passwd = "your-password",
                         .verbose = TRUE){
  
  # step 1 - login
  link <- "http://www.inmet.gov.br/projetos/rede/pesquisa/inicio.php"
  bdmep_form_l <- bdmep_login_att(link, .email, .passwd)
  r <- httr::POST(link, body = bdmep_form_l, encode = "form")
  if (httr::status_code(r) == 200 & .verbose) {
    message("\n", "-.-.-.-.-.-.-.-.-.-.-.-.", "\n", 
            "station: " , .id, "\n")
  }
  # visualize(r)
  gc()
  
  # step 2 - get data
  url_data <- "http://www.inmet.gov.br/projetos/rede/pesquisa/gera_serie_txt.php?&mRelEstacao=XXXXX&btnProcesso=serie&mRelDtInicio=dd/mm/yyyy&mRelDtFim=DD/MM/YYYY&mAtributos=1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
  #url_data <- "http://www.inmet.gov.br/projetos/rede/pesquisa/gera_serie_txt.php?&mRelEstacao=83980&btnProcesso=serie&mRelDtInicio=01/01/1961&mRelDtFim=01/01/2017&mAtributos=1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
  
  # link to station data
  url_data <-  url_data %>%
    stringr::str_replace("XXXXX", as.character(.id)) %>%
    stringr::str_replace("dd/mm/yyyy", .sdate) %>%
    stringr::str_replace("DD/MM/YYYY", .edate) 
  
  # request data  
  r2 <- httr::GET(url_data)
  
  #httr::stop_for_status(r2)
  if (.verbose) {
    if (httr::status_code(r2) == 200) {
      message("Request data ok.", "\n")
    } else {
      httr::message_for_status(r2)    
    }
  }  
  
  if(httr::status_code(r2) != 200){
    msg <- httr::http_status(r2)$message
    xtidy <- data.frame(id = .id, 
                        request_status = msg, 
                        stringsAsFactors = FALSE)
    return(xtidy)
  }
  
  x <- r2 %>%
    httr::content('text') %>%
    textConnection(local = TRUE) %>%
    readLines()

  # tidy data and output
  xtidy <- bdmep_read(x)
  return(xtidy)
}

##' Import data from Brazilian meteorological stations
##' 
##' @importFrom dplyr %>%
##' @details The data are in sub-daily time scale. A minimum data quality control is applied to the data.
##' This include: a chronological sequence check; filling data from missing dates with NA; 
##' remove duplicated data. Time variables (year, month, day, hour) are aggregated into a POSIX object in UTC
##' 
##' @param ids a character vector with codes of meteorological stations
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
##' # download data for Santa Maria and Porto Alegre
##' metdata <- bdmep_import(ids = c("83936", "83967"), 
##'                         sdate = "01/01/1961",
##'                         edate = format(Sys.Date(), '%d/%m/%Y'),
##'                         email = "your-email",
##'                         passwd = "your-password",
##'                         verbose = TRUE)
##' head(metdata)
##' tail(metdata)
##' summary(metdata)
##' 
bdmep_import <- function(ids = c("83936", "83967") ,
                        sdate = "01/01/1961",
                        edate = format(Sys.Date(), '%d/%m/%Y'),
                        email = "your-email",
                        passwd = "your-password",
                        verbose = TRUE){
  
  purrr::map_df(ids, ~bdmep_import_station(.x, 
                               .sdate = sdate, 
                               .edate = edate, 
                               .email = email,
                               .passwd = passwd,
                               .verbose = verbose))
} 

##' Get metadata on meteorological stations
##'
##' Fetch the coordinates on meteorological stations from INMET
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
  
  txt <- httr::GET(link_stns_info) %>%
    httr::content('text') %>% 
    textConnection() %>%
    readLines() 
  
  closeAllConnections()
  rm(link_stns_info)
  
  txt_subset <- 
    txt %>%
    stringi::stri_trans_general("latin-ascii") %>%
    stringr::str_subset("Codigo OMM")
  
  txt_info_num <- txt_subset %>%
    stringr::str_extract_all("[-+]?([0-9]*\\.[0-9]+|[0-9]+)")
  
  #rm(txt)
  
  tab_info <- 
    txt_info_num %>%
    purrr::map_df(function(x){
      #x <- a
      n <- length(x)
      x[c(3, n - (2:0))] %>%
        matrix(nrow = 1) %>%
        dplyr::as_data_frame() %>%
        return()
    }) %>%
    setNames(c("id", "lat", "lon", "alt")) %>%
    dplyr::select_("id", "lon", "lat", "alt") %>%
    dplyr::mutate_at(dplyr::vars(dplyr::one_of(c("lat", "lon", "alt"))), as.numeric) %>%
    data.frame() 
  
  #tab_info <- dplyr::full_join(bdmep_stations(), tab_info, by = "id")
  
  return(tab_info)
} # end function bdmep_metadata


##' Get basic information on meteorological station from INMET
##'
##' This function is used to find the OMM station ID that can be
##' used to import BDMEP data using \code{\link{bdmep_import}}
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
    stringi::stri_trans_general("latin-ascii") %>%
    stringr::str_replace_all(" ", "_") %>%
    stringr::str_replace("_da", "") %>%
    setNames(tab, nm = .) %>%
    tidyr::separate(nome_estacao, c("nome", "estado"), sep = " - ")
  tab <- tab %>% 
    data.frame() %>%
    setNames(c("name", "state", "id")) %>%
    dplyr::mutate(id = as.character(id))
    return(tab)
}


##' Units of meteorological variables 
##'
##' This function describe the Meteorological variables imported with \code{\link{bdmep_import}}
##' @description Get variable names, description and units
##' @importFrom dplyr %>%
##' @details to information about instruments see \url{http://www.inmet.gov.br/portal/index.php?r=home/page&page=instrumentos}
##' @return a data frame is returned with 
##'  \code{varname}, \code{description}, \code{unit}
##' @export
##' @author Jonatan Tatsch
##' @examples 
##' met_vars <- bdmep_units()
##' met_vars
##' 
bdmep_units <- function() {
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
