#' Batch Geocode a File
#'
#' Submits a file of addresses to the `BatchGeocode` job endpoint.
#'
#' @param path String. Path to a CSV of addresses to upload and geocode.
#' @param field_mapping Named character vector mapping geocoder fields to
#'   columns in `path`, for example `c(SingleLine = "full_address")`.
#'   Case sensitive.
#' @param item_id String. Id of a CSV already in the portal. Use instead of `path`.
#' @param server_url String. Overrides the job URL derived from `geocoder`.
#' @inheritParams find_address_candidates
#' @export
#' @returns A `BatchGeocodeJob`.
#' @examples
#' \dontrun{
#' job <- geocode_file_job("addresses.csv", c(SingleLine = "full_address"))
#' job$await()
#' write_geocode_result(job, "geocoded.csv")
#' }
geocode_file_job <- function(
  path = NULL,
  field_mapping,
  ...,
  item_id = NULL,
  server_url = NULL,
  geocoder = default_geocoder(),
  token = arc_token()
) {
  rlang::check_dots_empty()
  check_string(server_url, allow_null = TRUE, allow_empty = FALSE)
  check_geocoder(geocoder)
  obj_check_token(token)
  check_character(field_mapping)

  if (is.null(names(field_mapping)) || !all(nzchar(names(field_mapping)))) {
    cli::cli_abort("{.arg field_mapping} must be named.")
  }

  rlang::check_exclusive(path, item_id)

  if (!is.null(path)) {
    item_id <- arcgisutils::upload_file(
      ensure_utf8_bom(path),
      basename(path),
      token = token
    )[["id"]]
  }

  check_string(item_id, allow_empty = FALSE)

  BatchGeocodeJob$new(
    base_url = server_url %||% batch_geocode_url(geocoder),
    item_id = item_id,
    field_mapping = field_mapping,
    token = token
  )
}

#' @title Batch Geocode Job
#' @description
#' A [`arcgisutils::arc_gp_job`] for the `BatchGeocode` endpoint, which takes a
#' JSON body and reports status over `POST`.
#' @export
BatchGeocodeJob <- R6::R6Class(
  "BatchGeocodeJob",
  inherit = arcgisutils::arc_gp_job,
  public = list(
    #' @field item_id the portal item holding the uploaded addresses.
    item_id = NULL,
    #' @param base_url the URL of the job service, without `/submitJob`.
    #' @param item_id the id of the portal item holding the addresses.
    #' @param field_mapping a named character vector of geocoder field to column.
    #' @param token an [`arcgisutils::arc_token()`].
    initialize = function(base_url, item_id, field_mapping, token = arc_token()) {
      self$item_id <- item_id
      super$initialize(
        base_url = base_url,
        params = list(
          f = "json",
          item = as.character(jsonify::to_json(list(itemID = item_id), unbox = TRUE)),
          fieldMapping = collapse_field_mapping(field_mapping)
        ),
        token = token
      )
    },
    #' @description Submits the job. The endpoint requires a JSON body.
    start = function() {
      res <- private$post("submitJob", self$params@params)
      self$id <- res[["jobId"]]
      self
    },
    #' @description Downloads the geocoded file.
    #' @param path where to write the result CSV.
    write = function(path) {
      check_string(path, allow_empty = FALSE)
      private$check_succeeded()

      zip <- tempfile(fileext = ".zip")
      on.exit(unlink(zip), add = TRUE)

      arc_base_req(self$results, private$token) |>
        httr2::req_perform(path = zip)

      inner <- utils::unzip(zip, list = TRUE)[["Name"]]

      if (length(inner) != 1L) {
        cli::cli_abort("Expected one file in the result, found {length(inner)}.")
      }

      out <- utils::unzip(zip, files = inner, exdir = tempdir(), junkpaths = TRUE)
      on.exit(unlink(out), add = TRUE)
      file.copy(out, path, overwrite = TRUE)

      invisible(path)
    }
  ),
  active = list(
    #' @field status the job status as an [`arcgisutils::arc_job_status()`].
    status = function() {
      if (is.null(self$id)) {
        return(NULL)
      }
      arcgisutils::arc_job_status(private$post(c("jobs", self$id))[["jobStatus"]])
    },
    #' @field results the URL of the geocoded file.
    results = function() {
      private$check_started()
      res <- private$post(c("jobs", self$id, "results", "geocodeResult"))
      res[["value"]][["url"]]
    }
  ),
  private = list(
    post = function(path, body = NULL) {
      req <- arc_base_req(self$base_url, private$token, path = path)

      if (!is.null(body)) {
        req <- httr2::req_body_raw(
          req,
          as.character(jsonify::to_json(body, unbox = TRUE)),
          type = "application/json"
        )
      }

      res <- RcppSimdJson::fparse(
        httr2::resp_body_string(
          httr2::req_perform(
            httr2::req_error(
              httr2::req_method(req, "POST"),
              is_error = function(e) FALSE
            )
          )
        )
      )

      detect_errors(res)
      res
    },
    check_succeeded = function() {
      status <- self$status@status

      if (!identical(status, "esriJobSucceeded")) {
        msg <- private$post(c("jobs", self$id))[["messages"]]
        cli::cli_abort(c(
          "Job {.val {self$id}} is {.val {status}}.",
          rlang::set_names(msg[["description"]], "x")
        ))
      }
    },
    check_started = function() {
      if (is.null(self$id)) {
        cli::cli_abort(c(
          "There is no job ID present.",
          ">" = "Have you started the job with {.code x$start()}?"
        ))
      }
    }
  )
)

collapse_field_mapping <- function(field_mapping) {
  paste0(names(field_mapping), ":", unname(field_mapping), collapse = ",")
}

#' Write Batch Geocoding Results
#'
#' Downloads the result of a completed [`geocode_file_job()`].
#'
#' @param job A `BatchGeocodeJob`.
#' @param path String. Where to write the result CSV.
#' @export
#' @returns `path`, invisibly.
#' @examples
#' \dontrun{
#' write_geocode_result(job, "geocoded.csv")
#' }
write_geocode_result <- function(job, path) {
  if (!inherits(job, "BatchGeocodeJob")) {
    cli::cli_abort("{.arg job} must be a {.cls BatchGeocodeJob}.")
  }

  job$write(path)
}

#' @rdname geocode_file_job
#' @param out String. Where to write the result CSV.
#' @param interval Number. Seconds between status checks.
#' @export
geocode_file <- function(
  path,
  field_mapping,
  out,
  ...,
  interval = 5,
  geocoder = default_geocoder(),
  token = arc_token()
) {
  job <- geocode_file_job(
    path,
    field_mapping,
    geocoder = geocoder,
    token = token
  )

  job$start()
  job$await(interval = interval)
  write_geocode_result(job, out)
}

# the job endpoint is a GPServer sibling of the GeocodeServer
batch_geocode_url <- function(geocoder, call = rlang::caller_env()) {
  url <- sub("/GeocodeServer/?$", "/GPServer/BatchGeocode", geocoder[["url"]])

  if (!grepl("/GPServer/BatchGeocode$", url)) {
    cli::cli_abort(
      "{.arg geocoder} does not support the {.path /BatchGeocode} endpoint.",
      call = call
    )
  }

  url
}

# the service requires the uploaded CSV to carry a UTF-8 byte order mark
ensure_utf8_bom <- function(path) {
  con <- file(path, "rb")
  on.exit(close(con), add = TRUE)
  bom <- as.raw(c(0xef, 0xbb, 0xbf))

  if (identical(readBin(con, "raw", 3L), bom)) {
    return(path)
  }

  body <- readBin(path, "raw", file.size(path))
  out <- tempfile(fileext = paste0(".", tools::file_ext(path)))
  writeBin(c(bom, body), out)
  out
}
