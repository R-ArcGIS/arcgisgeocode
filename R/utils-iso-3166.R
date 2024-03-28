#' ISO 3166 Country Codes
#'
#' Create a data.frame of ISO 3166 2 and 3 digit Country codes.
#'
#' @details
#' Country codes provided by [`rust_iso3166`](https://docs.rs/rust_iso3166/latest/rust_iso3166/index.html).
#'
#' @returns a `data.frame` with columns `country`, `code_2`, `code_3`.
#' @export
#' @examples
#' head(iso_3166_codes())
iso_3166_codes <- function() {
  codes <- data.frame(
    country = iso_3166_names(),
    code_2 = iso_3166_2(),
    code_3 = iso_3166_3()
  )
  data_frame(codes)
}


#' Add `tbl` class to a data.frame
#'
#' When pillar is loaded, a data.frame will print like a tibble
#' but will not inherit the tibble class.
#'
#' @noRd
#' @keywords internal
data_frame <- function(x, call = rlang::caller_env()) {
  check_data_frame(x, call = call)
  structure(x, class = c("tbl", "data.frame"))
}
