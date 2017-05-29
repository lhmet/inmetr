# UNDER CONSTRUCTION

# x <- bdmep_import(id = c("82915","83235"),
#                         sdate = "01/01/1961",
#                          edate = format(Sys.Date(), '%d/%m/%Y'),
#                          email = "your-email",
#                          passwd = "your-password",
#                          verbose = TRUE)



mean_thresh <- function(x, thresh = 0) {
  # x <- c(NA, NA, 1,2,3, NA, 4)
  if(sum(!is.na(x))/length(x) * 100 <  thresh){
    return(NA)  
  }
    mean(x, na.rm = TRUE)
}

data_cap <- function(x, percent = FALSE){ 
   if(percent) sum(!is.na(x))/length(x) * 100
  sum(!is.na(x))
}

bdmep_summary <- function(x, data_thresh = 0, meta_data){
  offset_utc <- time_zone <- n <- NULL
  # xo -> x
  # remove estações indisponíveis (Bad Request (HTTP 400))
  x <- tibble::as_tibble(x) %>%
    dplyr::filter(., !is.na(date)) %>%
    dplyr::select(., -request_status) 
  
  meta_data <- dplyr::filter(meta_data, id %in% unique(x$id)) %>%
               dplyr::select(., dplyr::one_of(c("id", "time_zone", "offset_utc")))
  
  
  x <- dplyr::full_join(x, meta_data, by = "id")
  
  lt2utc <- function(x, tzone) {
    lubridate::with_tz(x, tzone[1]) %>%
    lubridate::force_tz(., "UTC")
  }
  
  x <- dplyr::group_by(x, id) %>%
    dplyr::do(dplyr::mutate(., 
                            #date_ = lt2utc(x = .$date,
                            date = lt2utc(x = .$date,
                                           tzone = unique(.$time_zone))
                            )
              ) %>%
    dplyr::ungroup() %>%
    dplyr::select(-offset_utc, -time_zone)
  
  # check <- dplyr::select(x, date, date_); head(check); tail(check)
  # check <- dplyr::select(x, date); head(check); tail(check)
  # a <- x %>% group_by(id, day = as.Date(date_)) %>% summarise(N = n()) %>% ungroup() %>% dplyr::rename("date" = day)
  # timePlot(a, "N" ,type = "id")
  # Amostragem irregular do INMET
  x <- dplyr::rename(x, "site" = id)
  y <- x %>%
    dplyr::group_by(site, date = lubridate::as_date(date)) %>% 
    dplyr::summarise(N = n()) %>%
    dplyr::ungroup()
  
  #ta <- timeAverage(x, avg.time = "day", statistic = "frequency", type = "site")
  
  z <- x %>%
    dplyr::select(date, site, wd) %>%
    dplyr::group_by(site, date = lubridate::as_date(date)) %>%
    dplyr::summarise(N = n(), valid = data_cap(wd, percent = FALSE)) 
  
  # 1 regularizar series
  # 2 considerar TZ e obter para cada EST a data de acordo com o fuso horário local 
  # 3. agrupar por EST e DAY
  # 4. calcular a disp. de dados e de acordo com o limiar aplicar a média ou não

  
  # complete dates 
  y <- x %>%
    dplyr::group_by(id, day = lubridate::as_date(date)) %>%
    dplyr::summarise_at(.cols = dplyr::vars(-c(prec, request_status, date, ws, wd )),
                        dplyr::funs(avg = mean_thresh(., thresh = data_thresh),
                             n = data_cap(., percent = FALSE)) 
                        ) %>%
    dplyr::rename("date" = day) %>%
    dplyr::ungroup() %>%
    setNames(., gsub("_avg", "", names(.)))
  y[is.na(y)] <- NA
  
  y
  
  
}