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
#'  @details First the function try read metadata in ./data/bdmep_meta.RData.
#'   If it was not found, it is downloaded from \url{http://www.inmet.gov.br/webcdp/climatologia/normais/imagens/normais/planilhas/Relac_Est_Meteo_NC.xls}
#'   and saved at ./inst/extdata as \emph{bdmep_meta.xls}
bdmep_metadata_normclim <- function(metadata_file = "./data/bdmep_meta.rda",
                                    verbose = TRUE){
  
  if(!file.exists(metadata_file)){
    ext_data_file <- "./data-raw/relac_est_meteo_nc.xls"
    if(!file.exists(ext_data_file)){
      # download excel file
      stn_meteo_nc_xls <- "http://www.inmet.gov.br/webcdp/climatologia/normais/imagens/normais/planilhas/Relac_Est_Meteo_NC.xls"
      invisible(download.file(stn_meteo_nc_xls, destfile = ext_data_file))
    }
    # import data from xls
    bdmep_meta <- read_meteo_stn_xls(ext_data_file, verbose)
    # save clean data
    save(bdmep_meta, file = metadata_file)
    return(bdmep_meta)
  }
  
  # clean data
  load(metadata_file)
  return(bdmep_meta)
  
} # end function bdmep_metadata_normclim


# Generate data ------------------------------------------------
bdmep_meta <- bdmep_metadata_normclim("./data/bdmep_meta.rda", verbose = FALSE)

