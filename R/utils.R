utils::globalVariables(c(
  ".", "data", "hora", "codigo",
  "prec", "site",
  "ws", "tcomp", "id", "request_status",
  "wd", "day", "ws", "xtidy", ".verbose",
  ".na.strings", ".destdir", "rows",
  "nome_estacao"
))

#' Pipe operator
#'
#' See \code{\link[dplyr]{\%>\%}} for more details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom dplyr %>%
#' @usage lhs \%>\% rhs
NULL


#' Detect if a string is empty
#'
#' @param string Input vector. Either a character vector, or something coercible to one.
#'
#' @return logical, TRUE in the absence of a string (""), otherwise FALSE.
str_empty <- function(string) {
  string <- as.character(string)
  string == ""
}


#' Count valid data
#'
#' @param x a numeric vector
#'
#' @return total non-missing values of x.
#'
nvalid <- function(x) {
  # if(all(is.na(x))) return(0)
  sum(!is.na(x))
}



bdmep_write_csv <- function(data_bdmep = xtidy,
                            folder = .destdir,
                            na.strings = .na.strings,
                            verbose = .verbose) {
  # if(!stringr::str_detect(.destfile, "\\.[a-z]{3,}")){
stopifnot(
  dir.exists(folder),
  all(c(
    "date", "id", "request_status",
    "prec", "ws"
  ) %in% names(data_bdmep))
)
  .id <- data_bdmep[1, "id"]
  .file <- file.path(folder, paste0(.id, ".csv"))

  # readr::write_csv(x = dplyr::mutate(xtidy, date = as.character(date)),
  readr::write_csv(
    x = data_bdmep,
    path = .file,
    na = na.strings,
    append = FALSE
  )

  if (file.exists(.file)) {
    if (verbose) message("Data saved in ", .file)
    res <- .file
  } else {
    message("Cannot save data file ", .file)
    res <- NA_character_
  }
  return(invisible(res))
}



#' Report status of each variable
#'
#' @param data_bdmep data processed by \code{\link{bdmep_read}} in
#' \code{\link{bdmep_import_station}}.
#'
#' @return data frame with the percentage of valid observations for each variable
##'  \describe{
##'    \item{id}{station id}
##'    \item{sdate}{start date of observations}
##'    \item{edate}{end date of observations}
##'    \item{rows}{number of rows in data file}
##'    \item{request_status}{character scalar with information on the status of a request}
##'    \item{prec}{valid observations of prec in percentage}
##'    \item{...}{valid observations of ith variable in percentage}
##'    \item{ws}{valid observations of ws in percentage}
##'  }
#'
bdmep_data_status <- function(data_bdmep = xtidy) {

stopifnot(
  all(
    c(
      "date", "id", "request_status",
      "prec", "ws"
    ) %in% names(data_bdmep)
  )
)

data_avail <- dplyr::select(
  data_bdmep, date, id, request_status
) 
data_avail <- dplyr::group_by(data_avail, id)
data_avail <- dplyr::summarise(
  data_avail,
  sdate = min(date, na.rm = TRUE),
  edate = max(date, na.rm = TRUE),
  rows = length(date),
  request_status = unique(request_status)
)

  data_status <- dplyr::select(data_bdmep, -date)
  data_status <- dplyr::group_by(data_bdmep, id)
  data_status <- dplyr::summarise_at(
    data_status,
    .vars = dplyr::vars(prec:ws),
    .funs = dplyr::funs(nvalid)
  )
  data_status <- dplyr::full_join(
    data_avail,
    data_status,
    by = "id"
  )
  data_status <- dplyr::mutate_at(
    data_status,
    dplyr::vars(prec:ws),
    .funs = dplyr::funs(. / rows * 100)
  )

  return(data_status)
}