utils::globalVariables(c(".", "data", "hora", "codigo", 
                         "nome_estacao","prec", "site",
                         "ws", "tcomp", "id", "request_status"))

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


