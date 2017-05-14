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




#' Clean column names of a data frame obtained a excel file  
#'
#' @param x data frame, tibble or data_frame 
#' @details This functions is used in \code{\link{read_meteo_stn_xls}} 
#' @return data frame with names id, nome, estado, uf, lat, lon, alt
#'
clean_col_names <- function(x){
  x -> .
  setNames(., stringr::str_trim(names(.))) -> .
  setNames(., 
           stringi::stri_trans_general(names(.),
                                       "latin-ascii")
  ) -> .
  dplyr::select(., -dplyr::contains("Colunas")) -> .
  setNames(., stringr::str_replace(names(.), " ", "_")) -> .
  setNames(., stringr::str_replace(names(.), "\\'", "")) -> .
  setNames(., stringr::str_replace(names(.), "\\(", "")) -> .
  setNames(., stringr::str_replace(names(.), "\\)", "")) -> .
  setNames(., stringr::str_replace(names(.), "\\°", "")) -> .
  setNames(., stringr::str_replace(names(.), "\\º", "")) -> .
  setNames(., stringr::str_replace(names(.), " ", "_")) -> .
  setNames(., stringr::str_replace(names(.), "\\`", "_")) -> .
  setNames(., stringr::str_replace(names(.), "_m", "")) -> .
  setNames(., tolower(names(.))) -> .
  dplyr::rename(.,
                "lon" = longitude,
                "lat" = latitude,
                "alt" = altitude,
                "id" = codigo) -> .
  dplyr::mutate(., id = as.character(id)) -> .
  x <- .; rm(.)
  return(x)
}



#' Convert a character string with information of spatial coordinates (lon, lat) to numeric
#'
#' @param x character vector 
#' @details This function is used to clean data in \code{\link{read_meteo_stn_xls}}
#' @return numeric vector
#'
parse_coords <- function(x){
  x <- stringr::str_replace(x, "\\º|\\°", "_")
  x <- stringr::str_replace(x, "\\'", "_")
  xl <- lapply(strsplit(x, "_"), 
         function(string) {
           ifelse(string[3] %in% c("S", "W"), 
                  (as.numeric(string[1]) + as.numeric(string[2])/60)*-1,  
                  (as.numeric(string[1]) + as.numeric(string[2])/60))
         })
  return(unlist(xl))
}


#' Read excel file with metadata of INMET's climate stations. 
#' @param file  path to excel file download from alternative link to climate stations from INMET
#' @param verbose logical, if TRUE show messages. 
#' @details The \code{file} is download from \url{http://www.inmet.gov.br/webcdp/climatologia/normais/imagens/normais/planilhas/Relac_Est_Meteo_NC.xls}.
#' This function is used in \code{\link{bdmep_metadata_normclim}}.
#' @return data frame with variables \code{id}, \code{lon}, \code{lat}, \code{alt}, \code{nome}, \code{estado}, \code{uf}. 
read_meteo_stn_xls <- function(file = "./inst/extdata/relac_est_meteo_nc.xls",
                               verbose = FALSE) {
  read_excel_quiet <- purrr::quietly(readxl::read_excel)
  # workaround Unwanted printed output from read_excel
  out <- read_excel_quiet(file, col_names = TRUE)
  if(verbose) warning(out$warnings)
  stn_meteo_nc <- out$result
  
  # clean names
  stn_meteo_nc <- clean_col_names(x = stn_meteo_nc)
  stn_meteo_nc <- dplyr::filter(stn_meteo_nc, !is.na(id))
  # stn_meteo_nc$lon -> x
  # clean data
  stn_meteo_nc <- dplyr::mutate(stn_meteo_nc, 
                                lat = parse_coords(lat),
                                lon = parse_coords(lon))
  stn_meteo_nc <- dplyr::select(stn_meteo_nc, 
                                dplyr::one_of("id", "lon", "lat", "alt", "nome", "estado", "uf"))
  stn_meteo_nc <- dplyr::rename(stn_meteo_nc,
                                "state" = estado,
                                "name" = nome)
  return(as.data.frame(stn_meteo_nc))
  }


#' Get metadata on meteorological stations from alternative link to climate stations from INMET
#'
#' @importFrom readxl read_excel
#' @return data frame with variables:
#'  \code{id}, \code{lon}, \code{lat}, \code{alt}, 
#'  \code{name}, \code{state}, \code{uf}.
#'  @details First the function try read metadata in ./data/relac_est_meteo_nc.RData.
#'   If it was not found, it is downloaded from \url{http://www.inmet.gov.br/webcdp/climatologia/normais/imagens/normais/planilhas/Relac_Est_Meteo_NC.xls}
#'   and saved at ./inst/extdata as \emph{relac_est_meteo_nc.xls}
#'    
#' @examples
#'  metadt <- bdmep_metadata_normclim()
#'  head(metadt)
bdmep_metadata_normclim <- function(metadata_file = "./data/relac_est_meteo_nc.rda",
                                    verbose = TRUE){
  
  if(!file.exists(metadata_file)){
    ext_data_file <- "./inst/extdata/relac_est_meteo_nc.xls"
    if(!file.exists(ext_data_file)){
      # download excel file
      stn_meteo_nc_xls <- "http://www.inmet.gov.br/webcdp/climatologia/normais/imagens/normais/planilhas/Relac_Est_Meteo_NC.xls"
      
      invisible(download.file(stn_meteo_nc_xls, destfile = ext_data_file))
    }
      # import data from xls
      relac_est_meteo_nc <- read_meteo_stn_xls(ext_data_file, verbose)
      # save clean data
      save(relac_est_meteo_nc, file = metadata_file)
      return(relac_est_meteo_nc)
  }
  
  # clean data
  load(metadata_file)
   return(relac_est_meteo_nc)
  
} # end function bdmep_metadata_normclim



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


