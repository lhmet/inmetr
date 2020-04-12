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
bdmep_read <- function(x) {

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
  h_fix <- gsub(" ", "", as.character(h_fix))

  ## replace original vnames by the new ones
  # new_vnames <- c("codigo", "data","hora",
  #                 "prec", "tair", "tw", "tmax", "tmin", "urmax",
  #                 "patm", "pnmm", "wd", "wsmax", "n", "cc", "evap", "tcomp", "ur", "ws")
  # vnames <-  doBy::recodeVar(as.character(h_fix),
  #                            src = as.list(as.character(h_fix)),
  #                            tgt = as.list(new_vnames))

  vnames <- dplyr::recode(h_fix,
    Estacao = "codigo",
    Data = "data",
    Hora = "hora",
    Precipitacao = "prec",
    TempBulboSeco = "tair",
    TempBulboUmido = "tw",
    TempMaxima = "tmax",
    TempMinima = "tmin",
    UmidadeRelativa = "urmax",
    PressaoAtmEstacao = "patm",
    PressaoAtmMar = "pnmm",
    DirecaoVento = "wd",
    VelocidadeVento = "wsmax",
    Insolacao = "n",
    Nebulosidade = "cc",
    EvaporacaoPiche = "evap",
    TempCompMedia = "tcomp", # unnecessary, but recode can deal with
    UmidadeRelativaMedia = "ur",
    VelocidadedoVentoMedia = "ws"
  )

  x_clean <- x %>%
    magrittr::extract((rowheader + 1):(length(x) - 1)) %>%
    stringr::str_replace(";$", "")

  bdmepd <- read.csv2(
    text = x_clean,
    header = FALSE,
    stringsAsFactors = FALSE,
    na.strings = ""
  )
  bdmepd <- tibble::as_tibble(bdmepd)

  # stop if there is conflict between ncol(x) and length(hvec)
  if (ncol(bdmepd) != length(vnames)) {
    print(head(bdmepd))
    cat(
      "ncol(x) = ", ncol(bdmepd), "\n",
      "hvec = ", vnames, "\n", "\n"
    )

    stop("num. of data columns does not match the num. of variables")
  } else {
    names(bdmepd) <- vnames
  } # end if

  # bdmepd_bck <- bdmepd

  # coercion to numeric due to na.strings = ""
  sel_vars <- names(bdmepd)[!names(bdmepd) %in% c("codigo", "data", "hora")]
  bdmepd <- bdmepd %>%
    dplyr::mutate_at(sel_vars, as.numeric)

  ## date conversion
  bdmepd <- bdmepd %>%
    # dplyr::mutate(hora = doBy::recodeVar(as.character(hora),
    #                                      src = as.list(c("1800","0","1200")),
    #                                      tgt = as.list(c("18:00","00:00","12:00"))
    # ),
    dplyr::mutate(
      hora = dplyr::recode(as.character(hora),
        `1800` = "18:00",
        `0` = "00:00",
        `1200` = "12:00"
      ),
      date = as.POSIXct(paste(as.Date(data,
        format = "%d/%m/%Y"
      ),
      hora,
      sep = " "
      ),
      tz = "UTC"
      ),
      data = NULL,
      hora = NULL,
      id = as.character(codigo),
      codigo = NULL
    )
  # reorder columns
  bdmepd <- bdmepd %>%
    # dplyr::select(date, id, prec:ws, -tcomp)
    dplyr::select(date, id, prec:ws)

  # duplicated rows
  bdmepd <- dplyr::distinct(bdmepd)

  return(bdmepd)
} ## end function readInmet


#' Set username and password to login BDMEP
#'
#' @param lnk url to BDMEP access
#' @param email your BDMEP username
#' @param passwd your BDMEP password
#'
##' @return a named list with user name, password and text of button access
##' @author Jonatan Tatsch
##'
set_bdmep_user <- function(lnk, email, passwd) {
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
    rvest::html_attr("value")

  # put values in a named list
  l <- seq_along(vals_name_passwd_bt) %>%
    lapply(function(i) vals_name_passwd_bt[i]) %>%
    setNames(attrs_name_passwd_bt)
  # add email and passwd
  l <- purrr::update_list(l, mCod = email, mSenha = passwd)
  return(l)
}



bdmep_rawdata <- function(id = "83844",
                          sdate = "01/01/1961",
                          edate = format(Sys.Date(), "%d/%m/%Y"),
                          email,
                          passwd,
                          verbose = TRUE) {

  # step 1 - login
  link <- "http://www.inmet.gov.br/projetos/rede/pesquisa/inicio.php"
  bdmep_form_l <- set_bdmep_user(link, email, passwd)
  r <- httr::POST(link, body = bdmep_form_l, encode = "form")

  # to avoid getting flagged as a spammer
  Sys.sleep(1)

  if (httr::status_code(r) == 200 & verbose) {
    message(
      "\n", "------------------------------", "\n",
      "station: ", id
    )
  }
  # visualize(r)

  # step 2 - get data
  # all attributes selected - previous version
  # my_att <- "1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"

  # SOLUTION FOR ISSUE with "82098" MACAPA-AP station
  # excluding Temp Comp Media (which was removed after in bdmep_read)
  # before request data
  my_att <- "1,1,1,1,1,1,1,1,1,1,1,1,1,,1,1,"
  # 1,,,,,,,,,,,,,,,,# tair - TempBulboSeco
  # ,1,,,,,,,,,,,,,,,# tw - TempBulboUmido
  # ,,1,,,,,,,,,,,,,,# tmax - TempMaxima
  # ,,,1,,,,,,,,,,,,,# tmin - TempMinima
  # ,,,,1,,,,,,,,,,,,# ur - UmidadeRelativa
  # ,,,,,1,,,,,,,,,,,# patm - PressaoAtmEstacao
  # ,,,,,,1,,,,,,,,,,# pnmm - PressaoAtmMar
  # ,,,,,,,1,,,,,,,,,# wd - DirecaoVento
  # ,,,,,,,,1,,,,,,,,# ws - VelocidadeVento
  # ,,,,,,,,,1,,,,,,,# n - insolacao
  # ,,,,,,,,,,1,,,,,,# prec - precipitacao
  # ,,,,,,,,,,,1,,,,,# cc - Nebulosidade
  # ,,,,,,,,,,,,1,,,,# evap - Evaporacao Piche
  # ,,,,,,,,,,,,,1,,,# tcomp - Temp Comp Media
  # ,,,,,,,,,,,,,,1,,# ur - Umidade Relativa Media
  # ,,,,,,,,,,,,,,,1,# ws_avg - Velocidade do Vento Media

  url_data <- "http://www.inmet.gov.br/projetos/rede/pesquisa/gera_serie_txt.php?&mRelEstacao=XXXXX&btnProcesso=serie&mRelDtInicio=dd/mm/yyyy&mRelDtFim=DD/MM/YYYY&mAtributos=my_att"
  url_data <- gsub("my_att", my_att, url_data)
  # url_data <- "http://www.inmet.gov.br/projetos/rede/pesquisa/gera_serie_txt.php?&mRelEstacao=82098&btnProcesso=serie&mRelDtInicio=01/01/1961&mRelDtFim=30/04/2018&mAtributos=,,1,1,,,,,,1,1,,1,1,1,1,"
  # url_data <- "http://www.inmet.gov.br/projetos/rede/pesquisa/gera_serie_txt.php?&mRelEstacao=83980&btnProcesso=serie&mRelDtInicio=01/01/1961&mRelDtFim=01/01/2017&mAtributos=1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"

  # link to station data
  url_data <- url_data %>%
    stringr::str_replace("XXXXX", as.character(.id)) %>%
    stringr::str_replace("dd/mm/yyyy", sdate) %>%
    stringr::str_replace("DD/MM/YYYY", edate)

  # request data
  r2 <- httr::GET(url_data)

  # to avoid getting flagged as a spammer
  Sys.sleep(1)

  return(r2)
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
##' @param .na.strings a character string which is to be interpreted as NA values.
##' @return a data frame with variables in columns (see \code{\link{bdmep_description}}) and observations (date and time) along rows.
##' @author Jonatan Tatsch
##'
bdmep_import_station <- function(.id = "83844",
                                 .sdate,
                                 .edate,
                                 .email,
                                 .passwd,
                                 .verbose = TRUE,
                                 .destdir = NULL,
                                 .na.strings = "-9999") {

  # start and end dates are to the to the available span in bdmep_rawdata()
  r2 <- bdmep_rawdata(id = .id, email = .email, passwd = .passwd, verbose = .verbose)

  msg <- httr::http_status(r2)$message

  # httr::stop_for_status(r2)
  if (.verbose) {
    httr::message_for_status(r2)
    cat("\n")
  }

  # to deal with network connection problem, add column to inform request status
  if (httr::status_code(r2) != 200) {
    xtidy <- bdmep_template(.id, msg)
    return(xtidy)
  }

  # convert request data to text
  x <- r2 %>%
    httr::content("text") %>%
    textConnection(local = TRUE) %>%
    readLines()

  # if there are no data in database for 1961-current date
  pos_warn <- which(stringr::str_detect(x, "existem dados disp"))
  if (length(pos_warn) > 0) {
    msg_nodata <- stringr::str_replace(x[pos_warn], "<pre>", "")
    if (.verbose) message(msg_nodata)
    xtidy <- bdmep_template(.id, msg_nodata)
    return(xtidy)
  }

  # tidy data and output
  xtidy <- bdmep_read(x)

  # filter data for requested dates interval
  xtidy <- dplyr::filter(xtidy, date >= lubridate::dmy(.sdate) & date <= lubridate::dmy(.edate))
  if (nrow(xtidy) > 0) {
    date_span <- as.Date(range(xtidy$date))
    date_req <- as.Date(lubridate::dmy(c(.sdate, .edate)))
    check_dates_span <- dplyr::between(date_req, data_span[1], data_span[2])
    if (any(!isTRUE(check_dates_span))) {
      if (.verbose) message("Returning data available span: ", paste(date_span, collapse = "--"))
    }
  } else {
    # if there are no data in the requested span
    if (.verbose) {
      msg_nodata_req <- paste0(
        "Nao existem dados disponiveis da estacao: ",
        paste(c(
          t(
            dplyr::filter(bdmep_meta, id == .id) %>%
              dplyr::select(dplyr::one_of(c("name", "uf")))
          )
        ),
        collapse = "-"
        ),
        " para o periodo de ",
        .sdate,
        " a ",
        .edate
      )
      message(msg_nodata_req)
    }
    xtidy <- bdmep_template(.id, msg_nodata_req)
    return(xtidy)
  }


  # column with status
  xtidy <- dplyr::mutate(xtidy, request_status = msg)

  if (!is.null(.destdir)) {
    bdmep_write_csv(
      data_bdmep = xtidy,
      folder = .destdir,
      na.strings = .na.strings,
      verbose = .verbose
    )

    data_status <- bdmep_data_status(xtidy)
    return(data_status)
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
##' @param na.strings a character string which is to be interpreted as NA values. \code{na.strings} is only used when destdir is not NULL.
##'
##' @return A data frame with variables in columns (see \code{\link{bdmep_description}}) and observations (date and time) along rows.
##' @export
##' @author Jonatan Tatsch
##' @examples
##' \dontrun{
##' # download data for Santa Maria and Porto Alegre
##' metdata <- bdmep_import(id = c("83936", "83967"),
##'                         sdate = "01/01/2015", # could be "01/01/1961"
##'                         edate = format(Sys.Date(), '%d/%m/%Y'),
##'                         email = "your@email.com",
##'                         passwd = "your-password",
##'                         verbose = TRUE)
##' head(metdata)
##' tail(metdata)
##' summary(metdata)
##' }
##'
bdmep_import <- function(id = c("83844", "83967"),
                         sdate = "01/01/1961",
                         edate = format(Sys.Date(), "%d/%m/%Y"),
                         email = "your@email.com",
                         passwd = "your-password",
                         verbose = TRUE,
                         destdir = NULL,
                         na.strings = "-9999") {

  # check arguments precondition ----------------------------------------------
  id <- as.character(id)
  sdate <- stringr::str_trim(as.character(sdate))
  edate <- stringr::str_trim(as.character(edate))

  stopifnot(
    unique(nchar(id)) == 5,
    all(id %in% inmetr::bdmep_meta$id),
    length(unlist(stringr::str_extract_all(sdate, "/"))) == 2,
    length(unlist(stringr::str_extract_all(edate, "/"))) == 2,
    stringr::str_detect(email, "@"),
    is.character(passwd),
    is.logical(verbose),
    is.null(destdir) | is.character(destdir)
  )
  if (!is.null(destdir)) stopifnot(dir.exists(destdir))
  # import data ---------------------------------------------------------------
  purrr::map_df(id, ~ bdmep_import_station(.x,
    .sdate = sdate,
    .edate = edate,
    .email = email,
    .passwd = passwd,
    .verbose = verbose,
    .destdir = destdir,
    .na.strings = na.strings
  ))
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
bdmep_template <- function(.id, .req_status) {
  varnames <- bdmep_description()[, "varname"]
  templ_df <- as.data.frame(
    t(rep(NA, length(varnames))),
    stringsAsFactors = FALSE
  )
  templ_df <- templ_df %>%
    setNames(varnames) %>%
    dplyr::mutate(
      id = as.character(.id),
      request_status = as.character(.req_status)
    )
  templ_df
}