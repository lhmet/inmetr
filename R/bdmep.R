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
  if (ncol(bdmepd) != length(vnames)) {
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
                                         tgt = as.list(c("18:00","00:00","12:00"))
                                         ),
                  date = as.POSIXct(paste(as.Date(data,
                                                  format = "%d/%m/%Y"),
                                          hora,
                                          sep = " "), 
                                    tz = "UTC"),
                  data = NULL,
                  hora = NULL,
                  id = as.character(codigo),
                  codigo = NULL) 
  # reorder columns
  bdmepd <- bdmepd %>% 
    dplyr::select(date, id, prec:ws, -tcomp)
  
  # duplicated rows
    bdmepd <- dplyr::distinct(bdmepd)

    return(bdmepd)
  
}## end function readInmet


#' Set username and password to login BDMEP
#'
#' @param lnk url to BDMEP access
#' @param email your BDMEP username
#' @param passwd your BDMEP password 
#'
##' @return a named list with user name, password and text of button access
##' @author Jonatan Tatsch
##' 
set_bdmep_user <- function(lnk, email, passwd){
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
##' 
##' @details The data are in sub-daily time scale. A minimum data quality control is applied to the data.
##' This include: a chronological sequence check; filling data from missing dates with NA; 
##' remove duplicated data. Time variables (year, month, day, hour) are aggregated into a POSIX object in UTC
##' 
##' @param .id a character vector with the meteorological station code
##' @param .sdate start date in "d/m/Y" format
##' @param .edate end date in "d/m/Y" format, default values \code{format(Sys.Date(), "\%d/\%m/\%Y")}
##' @param .email e-mail to access BDMEP 
##' @param .passwd password to access BDMEP
##' @param .verbose Optional. Logical. If set to TRUE (default), print messages.
##' @param .destdir Optional. Character Local file path to write file out to.If NULL (default) files are not written to disk.
##' @param ... Additional arguments for the underlying export functions (see \code{\link{write_csv}}). 
##' @return a data frame with variables in columns (see \code{\link{bdmep_description}}) and observations (date and time) along rows.
##' @author Jonatan Tatsch
##' 
bdmep_import_station <- function(.id = "83488" ,
                                 .sdate = "01/01/1961",
                                 .edate = format(Sys.Date(), '%d/%m/%Y'),
                                 .email = "your-email",
                                 .passwd = "your-password",
                                 .verbose = TRUE,
                                 .destdir = NULL,
                                 ...){
  # step 1 - login
  link <- "http://www.inmet.gov.br/projetos/rede/pesquisa/inicio.php"
  bdmep_form_l <- set_bdmep_user(link, .email, .passwd)
  r <- httr::POST(link, body = bdmep_form_l, encode = "form")
  
  if (httr::status_code(r) == 200 & .verbose) {
    message("\n", "------------------------------", "\n", 
            "station: " , .id)
  }
  # visualize(r)
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
  
  msg <- httr::http_status(r2)$message
  
  #httr::stop_for_status(r2)
  if (.verbose) {
      httr::message_for_status(r2)
      cat("\n")
  }
  
  # column to inform request status
  if (httr::status_code(r2) != 200) {
    xtidy <- bdmep_template(.id , msg)
    return(xtidy)
  }
  
  x <- r2 %>%
    httr::content('text') %>%
    textConnection(local = TRUE) %>%
    readLines()
  
  # tidy data and output
  xtidy <- bdmep_read(x)
  # column with status
  xtidy <- dplyr::mutate(xtidy, request_status = msg)

  if (!is.null(.destdir)) {
    #if(!stringr::str_detect(.destfile, "\\.[a-z]{3,}")){
    .file <- file.path(.destdir, paste0(.id, ".csv"))
    if (.verbose) message("Data saved in ", .file)
    #readr::write_csv(x = dplyr::mutate(xtidy, date = as.character(date)),
    readr::write_csv(x = xtidy,
                     path = .file,
                     ...)
  }
  return(xtidy)
}

##' Import data from Brazilian meteorological stations
##' 
##' @importFrom dplyr %>%
##' @details The data are in sub-daily time scale. A minimum data quality control is applied to the data.
##' This include: a chronological sequence check; filling data from missing dates with NA; 
##' remove duplicated data. Time variables (year, month, day, hour) are aggregated into a POSIX object in UTC
##' 
##' @param id A character vector with codes of meteorological stations
##' @param sdate Start date in "d/m/Y" format
##' @param edate End date in "d/m/Y" format, default values \code{format(Sys.Date(), "\%d/\%m/\%Y")}
##' @param email E-mail to access BDMEP 
##' @param passwd Password to access BDMEP
##' @param verbose If TRUE, prints login sucessfull.
##' @param destdir A character string with the path where the downloaded data is saved. If it is  NULL, data will not be saved in disk.
##' @param ... Additional arguments for the underlying function \code{\link{write_csv}}.
##' 
##' @return A data frame with variables in columns (see \code{\link{bdmep_description}}) and observations (date and time) along rows.
##' @export
##' @author Jonatan Tatsch
##' @examples 
##' # download data for Santa Maria and Porto Alegre
##' metdata <- bdmep_import(id = c("83936", "83967"), 
##'                         sdate = "01/01/1961",
##'                         edate = format(Sys.Date(), '%d/%m/%Y'),
##'                         email = "your-email",
##'                         passwd = "your-password",
##'                         verbose = TRUE)
##' head(metdata)
##' tail(metdata)
##' summary(metdata)
##' 
bdmep_import <- function(id = c("83936", "83967") ,
                         sdate = "01/01/1961",
                         edate = format(Sys.Date(), '%d/%m/%Y'),
                         email = "your@email.com",
                         passwd = "your-password",
                         verbose = TRUE,
                         destdir = NULL,
                         ...){
  id <- as.character(id)
  # check arguments precondition ----------------------------------------------
  stopifnot(unique(nchar(id)) == 5,
            all(id %in% inmetr::bdmep_meta$id),
            length(unlist(stringr::str_extract_all(sdate, "/"))) == 2,
            length(unlist(stringr::str_extract_all(edate, "/"))) == 2,
            stringr::str_detect(email, "@"),
            is.character(passwd),
            is.logical(verbose),
            is.null(destdir) | is.character(destdir)
            )
  if(!is.null(destdir)) stopifnot(dir.exists(destdir))
  # import data ---------------------------------------------------------------
  purrr::map_df(id, ~bdmep_import_station(.x, 
                                           .sdate = sdate, 
                                           .edate = edate, 
                                           .email = email,
                                           .passwd = passwd,
                                           .verbose = verbose,
                                           .destdir = destdir,
                                           ...))
} 


#' Template bdmep dataframe to be used when the status of a request was not successfully executed.
#' 
#' @details This is used when the status of a request code is not 200.
#' 
#' @param .id a character scalar with the meteorological station code
#' @param .req_status character scalar with information on the status of a request
#' 
#' @importFrom dplyr %>%
#' @return a dataframe with variables filled with NA, except for id and request_status
bdmep_template <- function(.id, .req_status){
  varnames <- bdmep_description()[, "varname"]
  templ_df <- as.data.frame(t(rep(NA, length(varnames))), stringsAsFactors = FALSE) 
  templ_df <- templ_df %>%
    setNames(varnames) %>%
    dplyr::mutate(id = as.character(.id),
                  request_status = as.character(.req_status))
  templ_df
}