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


bdmep_metadata_normclim <- function(){
  
  stn_meteo_nc_xls <- "http://www.inmet.gov.br/webcdp/climatologia/normais/imagens/normais/planilhas/Relac_Est_Meteo_NC.xls"
  tmp_file <- paste0(tempfile(), ".xls")
  download.file(stn_meteo_nc_xls, destfile = tmp_file)
   stn_meteo_nc <- readxl::read_excel(tmp_file, col_names = TRUE)
   #file.remove(tmp_file)
   
   # clean names
   stn_meteo_nc -> .
   setNames(., 
            stringi::stri_trans_general(names(.),
                                        "latin-ascii")
   ) -> .
   dplyr::select(., -dplyr::contains("Colunas")) -> .
   setNames(., stringr::str_replace(names(.), " ", "_")) -> .
   setNames(., stringr::str_replace(names(.), "\\'", "")) -> .
   setNames(., stringr::str_replace(names(.), "\\(", "")) -> .
   setNames(., stringr::str_replace(names(.), "\\)", "")) -> .
   setNames(., stringr::str_replace(names(.), "°", "")) -> .
   setNames(., stringr::str_replace(names(.), "º", "")) -> .
   setNames(., stringr::str_replace(names(.), " ", "_")) -> .
   setNames(., stringr::str_replace(names(.), "\\`", "_")) -> .
   setNames(., stringr::str_replace(names(.), "_m", "")) -> .
   setNames(., tolower(names(.))) -> .
   
   stn_meteo_nc <- .; rm(.)
  # data clean
   stn_meteo_nc -> .
   dplyr::mutate(., 
          latitude = stringr::str_replace(latitude, "º|°", "_"),
          longitude = stringr::str_replace(longitude, "º|°", "_"),
          latitude = stringr::str_replace(latitude, "\\'", "_"),
          longitude = stringr::str_replace(longitude, "\\'", "_"))
   
  # PAREI AQUI
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
  
  ## remove colum named " "
  tab <- tab %>%
    names() %>%
    stringr::str_trim(.) %>%
    purrr::discard(str_empty) %>%
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

##' Description of meteorological variables 
##'
##' This function describe the Meteorological variables imported by \code{\link{bdmep_import}}
##' @description Get variable names, description and units
##' @importFrom dplyr %>%
##' @details to information about instruments see \url{http://www.inmet.gov.br/portal/index.php?r=home/page&page=instrumentos}
##' @return a data frame is returned with 
##'  \code{varname}, \code{description}, \code{unit}
##' @export
##' @author Jonatan Tatsch
##' @examples 
##' met_vars <- bdmep_description()
##' met_vars
##' 
bdmep_description <- function() {
  desc <- data.frame(varname = c("date", 
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
                                     "wind speed"),
                     unit = c("-",
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
                              "m/s"),
                     stringsAsFactors = FALSE)
  new_line <- dplyr::data_frame(varname = "request_status",
                                description = "Information on the status of a request",
                                unit = NA_character_)
  desc <- dplyr::bind_rows(desc, new_line)
  return(desc)
}


