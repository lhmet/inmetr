utils::globalVariables(c(
  ".", "data", "hora", "codigo",
  "nome_estacao", "prec", "site",
  "ws", "tcomp", "id", "request_status",
  "wd", "day", "ws"
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
#' @param x
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
                            verbose = .verbose){
  # if(!stringr::str_detect(.destfile, "\\.[a-z]{3,}")){
  stopifnot(dir.exists(folder), 
            all(c("date", "id", "request_status", "prec", "ws") %in% names(data_bdmep))
            )
  .id <- data_bdmep[1, "id"]
  .file <- file.path(folder, paste0(.id, ".csv"))
  
  # readr::write_csv(x = dplyr::mutate(xtidy, date = as.character(date)),
  readr::write_csv(
    x = xtidy,
    path = .file,
    na = na.strings,
    append = FALSE
  )
  
  if(file.exists(.file)) {
    if (verbose) message("Data saved in ", .file)
    res <- .file
  } else {
    message("Cannot save data file ", .file)
    res <- NA_character_
  }
  return(invisible(res))
}



bdmep_data_status <- function(data_bdmep = xtidy){
  
  stopifnot(all(c("date", "id", "request_status", "prec", "ws") %in% names(data_bdmep)))
  
  out_summary <- data_bdmep %>%
    dplyr::select(date, id, request_status) %>%
    dplyr::group_by(id) %>%
    dplyr::summarise(.,
      sdate = min(date, na.rm = TRUE),
      edate = max(date, na.rm = TRUE),
      nrow = n(),
      request_status = unique(request_status)
    )
  
  data_status <- xtidy %>%
    dplyr::group_by(id) %>%
    dplyr::summarise_at(.,
                        .vars = dplyr::vars(prec:ws),
                        .funs = dplyr::funs(nvalid)
    ) %>%
    dplyr::full_join(out_summary, ., by = "id") %>%
    dplyr::mutate_at(dplyr::vars(prec:ws),
                     .funs = dplyr::funs(. / nrow * 100))
  
  return(data_status)
}
