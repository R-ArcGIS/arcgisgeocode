json_resp <- function(x) {
  httr2::response(
    status_code = 200L,
    headers = list(`Content-Type` = "application/json"),
    body = charToRaw(as.character(jsonify::to_json(x, unbox = TRUE)))
  )
}

fake_geocoder <- function(url = "https://example.com/arcgis/rest/services/World/GeocodeServer") {
  structure(list(url = url, capabilities = "Geocode,ReverseGeocode,Suggest"), class = c("GeocodeServer", "list"))
}

fake_token <- function() {
  httr2::oauth_token("1234", arcgis_host = "https://www.arcgis.com", username = "jdoe")
}

new_job <- function(...) {
  BatchGeocodeJob$new(
    base_url = "https://example.com/arcgis/rest/services/World/GPServer/BatchGeocode",
    item_id = "abc123",
    field_mapping = c(SingleLine = "full_address"),
    token = fake_token(),
    ...
  )
}

test_that("batch_geocode_url() swaps GeocodeServer for the GPServer task", {
  expect_identical(
    batch_geocode_url(fake_geocoder()),
    "https://example.com/arcgis/rest/services/World/GPServer/BatchGeocode"
  )
})

test_that("batch_geocode_url() rejects a URL it cannot map", {
  expect_error(batch_geocode_url(fake_geocoder("https://example.com/nope")), "BatchGeocode")
})

test_that("collapse_field_mapping() builds the wire format", {
  expect_identical(collapse_field_mapping(c(SingleLine = "addr")), "SingleLine:addr")
  expect_identical(
    collapse_field_mapping(c(Address = "street", City = "town")),
    "Address:street,City:town"
  )
})

test_that("the job builds its request parameters", {
  p <- new_job()$params@params

  expect_identical(p[["f"]], "json")
  expect_identical(p[["item"]], '{"itemID":"abc123"}')
  expect_identical(p[["fieldMapping"]], "SingleLine:full_address")
  expect_type(p[["item"]], "character")
})

test_that("start() posts JSON and records the job id", {
  job <- new_job()
  captured <- NULL

  httr2::local_mocked_responses(function(req) {
    captured <<- req
    json_resp(list(jobId = "job-1", jobStatus = "esriJobSubmitted"))
  })

  job$start()

  expect_identical(job$id, "job-1")
  expect_match(captured[["url"]], "/BatchGeocode/submitJob")
  expect_identical(captured[["method"]], "POST")
  expect_match(as.character(captured[["body"]][["data"]]), "abc123", fixed = TRUE)
})

test_that("status posts to the job and wraps the result", {
  job <- new_job()
  captured <- NULL

  httr2::local_mocked_responses(function(req) {
    captured <<- req
    json_resp(list(jobId = "job-1", jobStatus = "esriJobExecuting"))
  })

  job$start()
  st <- job$status

  expect_identical(st@status, "esriJobExecuting")
  expect_match(captured[["url"]], "/jobs/job-1$")
})

test_that("results returns the download URL", {
  job <- new_job()

  httr2::local_mocked_responses(function(req) {
    if (grepl("submitJob", req[["url"]], fixed = TRUE)) {
      return(json_resp(list(jobId = "job-1")))
    }
    json_resp(list(
      paramName = "geocodeResult",
      dataType = "GPDataFile",
      value = list(url = "https://example.com/download/job-1.zip")
    ))
  })

  job$start()
  expect_identical(job$results, "https://example.com/download/job-1.zip")
})

test_that("write() refuses a job that has not succeeded", {
  job <- new_job()

  httr2::local_mocked_responses(function(req) {
    if (grepl("submitJob", req[["url"]], fixed = TRUE)) {
      return(json_resp(list(jobId = "job-1")))
    }
    json_resp(list(
      jobId = "job-1",
      jobStatus = "esriJobFailed",
      messages = list(list(description = "UTF8 with BOM required"))
    ))
  })

  job$start()
  expect_error(job$write(tempfile()), "BOM")
})

test_that("write_geocode_result() requires a BatchGeocodeJob", {
  expect_error(write_geocode_result("nope", tempfile()), "BatchGeocodeJob")
})

test_that("ensure_utf8_bom() adds a BOM only when missing", {
  plain <- tempfile(fileext = ".csv")
  writeLines("a,b", plain)

  out <- ensure_utf8_bom(plain)
  expect_false(identical(out, plain))
  expect_identical(readBin(out, "raw", 3L), as.raw(c(0xef, 0xbb, 0xbf)))

  expect_identical(ensure_utf8_bom(out), out)
})

test_that("geocode_file_job() requires a named field_mapping", {
  expect_error(
    geocode_file_job(item_id = "abc", field_mapping = "full_address", geocoder = fake_geocoder(), token = fake_token()),
    "named"
  )
})

test_that("geocode_file_job() takes either a path or an item id", {
  expect_error(
    geocode_file_job(field_mapping = c(SingleLine = "a"), geocoder = fake_geocoder(), token = fake_token())
  )
})

test_that("server_url overrides the derived URL", {
  job <- geocode_file_job(
    item_id = "abc123",
    field_mapping = c(SingleLine = "a"),
    server_url = "https://custom.example.com/BatchGeocode",
    geocoder = fake_geocoder(),
    token = fake_token()
  )

  expect_identical(job$base_url, "https://custom.example.com/BatchGeocode")
})
