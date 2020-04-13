context("Time span")

test_that("Time span not available in database", {
  
  # template data -------------------------------------------------------------
  id <- "83743"
  # for a span not available in bdmep
  sdate <- format(Sys.Date() - 90, "%d/%m/%Y")
  edate <- format(Sys.Date(), "%d/%m/%Y")
  msg_nodata_req <- .build_msg_nodata(.id = id, .sdate = sdate, .edate = edate)
  data_ref <- bdmep_template(.id = id, .req_status = msg_nodata_req)
  
  # request data
  expect_message((data_req <- bdmep_import(id,
                                           sdate,
                                           edate,
                                           email = "jdtatsch@gmail.com",
                                           passwd = "d17ulev5",
                                           verbose = TRUE
  )), paste0("Nao existem dados disponiveis da estacao: Rio de Janeiro-RJ para o periodo de ", sdate, " a ", edate))
  
  expect_identical(data_req, data_ref)
})


test_that("Time span partially available in database", {
  
  # template data -------------------------------------------------------------
  id <- "83743"
  # for a span not avaialable in bdmep
  sdate <- "31/03/2002"
  edate <- format(Sys.Date(), "%d/%m/%Y")
  # msg_nodata_req <- .build_msg_nodata(.id = id, .sdate = sdate, .edate = edate)
  # data_ref <- bdmep_template(.id = id, .req_status = msg_nodata_req)
  
  # request data
  expect_message(
    (data_req <- bdmep_import(id,
                              sdate,
                              edate,
                              email = "jdtatsch@gmail.com",
                              passwd = "d17ulev5",
                              verbose = TRUE
    )),
    message(
      "\n", "------------------------------", "\n",
      "station: ", id, "\n",
      "\n",
      "OK (HTTP 200).",
      paste0(
        "Returning data available span: ",
        paste(as.Date((lubridate::dmy(sdate)))),
        "--",
        paste(as.Date(dplyr::last(data_req$date)))
      )
    )
  )
})



test_that("Time span not available in database 2", {
  
  # template data -------------------------------------------------------------
  id <- "83743"
  # for a span not available in bdmep
  sdate <- "01/01/1931"
  edate <- "31/12/1959"
  #msg_nodata_req <- .build_msg_nodata(.id = id, .sdate = sdate, .edate = edate)
  #data_ref <- bdmep_template(.id = id, .req_status = msg_nodata_req)
  
  # request data
  expect_message((data_req <- bdmep_import(id,
                                           sdate,
                                           edate,
                                           email = "jdtatsch@gmail.com",
                                           passwd = "d17ulev5",
                                           verbose = TRUE
  )), paste0("Nao existem dados disponiveis da estacao: Rio de Janeiro-RJ para o periodo de ", sdate, " a ", edate))
  
  #expect_identical(data_req, data_ref)
})
