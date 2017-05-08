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
#' @param string 
#'
#' @return logical, TRUE in the absence of a string (""), otherwise FALSE.
#'
#' @examples
str_empty <- function(string) {
  string == ""
} 