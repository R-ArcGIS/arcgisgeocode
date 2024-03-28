#' Convert a character vector to lower camel case
#' @param x a character vector
#' @keywords internal
#' @noRd
to_lower_camel <- function(x, call = rlang::caller_env()) {
  check_character(x, call = call, allow_null = TRUE)
  if (is.null(x)) {
    return(NULL)
  }
  vapply(strsplit(x, "_"), .lower_camel_case, character(1))
}

.lower_camel_case <- function(.x) {
  n <- length(.x)
  if (n == 1) {
    return(.x)
  }

  .x[2:n] <- tools::toTitleCase(.x[2:n])
  paste(.x, collapse = "")
}
