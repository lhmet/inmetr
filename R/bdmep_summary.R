

bdmep_summary <- function(x){
  #x <- xtidy
  x %>%
    dplyr::group_by(id, day = lubridate::day(date))
  
}