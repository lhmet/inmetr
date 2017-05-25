x <- bdmep_import(id = c("83936"), 
                        sdate = "01/01/1961",
                         edate = format(Sys.Date(), '%d/%m/%Y'),
                         email = "your-email",
                         passwd = "your-password",
                         verbose = TRUE)
                         


mean_tresh <- function(x, thresh = 0) {
  # x <- c(NA, NA, 1,2,3, NA, 4)
  if(sum(!is.na(x))/length(x) * 100 <  tresh){
    return(NA)  
  }
    mean(x, na.rm = TRUE)
}

data_cap <- function(x, percent = FALSE){ 
   if(percent) sum(!is.na(x))/length(x) * 100
  sum(!is.na(x))
}

bdmep_summary <- function(x, data_thresh = 0){
  
  # 1 regularizar series
  # 2 considerar TZ e obter para cada EST a data de acordo com o fuso horário local 
  # 3. agrupar por EST e DAY
  # 4. calcular a disp. de dados e de acordo com o limiar aplicar a média ou não
  
  #x <- xtidy
  tzone <- attr(x$date, "tzone")
  if (is.null(tzone)) tzone <- "UTC" 
  
  # complete dates 
  y <- x %>%
    dplyr::group_by(id, day = lubridate::as_date(date)) %>%
    dplyr::summarise_at(.cols = vars(-c(prec, request_status, date, ws, wd )),
                        funs(avg = mean_tresh(., thresh = data_thresh),
                             n = data_cap(., percent = FALSE)) 
                        ) %>%
    dplyr::rename("date" = day) %>%
    dplyr::ungroup() %>%
    setNames(., gsub("_avg", "", names(.)))
  y[is.na(y)] <- NA
  
  y
  
  
}