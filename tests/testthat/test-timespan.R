test_that("Requested time span not available in database", {

  # template data
  id <- "83743"
  sdate <- format(Sys.Date() - 90, "%d/%m/%Y")
  edate <- format(Sys.Date(), "%d/%m/%Y")
  msg_nodata_req <- .build_msg_nodata(.id = id, .sdate = sdate, .edate = edate)
  data_ref <- bdmep_template(.id = id, .req_status = msg_nodata_req)

  # request data
  data_req <- bdmep_import(id,
    sdate,
    edate,
    email = "jdtatsch@gmail.com",
    passwd = "d17ulev5",
    verbose = FALSE
  )

  expect_equal(data_req, data_ref)
})
