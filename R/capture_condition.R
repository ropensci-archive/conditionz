cc_generator <- function(condition = "message") {
  function(expr) {
    x <- NULL
    handler <- function(w) {
      x <<- c(x, list(w))
      switch(
        condition, 
        message = invokeRestart("muffleMessage"),
        warning = invokeRestart("muffleWarning")
      )
    }
    val <- switch(
      condition, 
      message = withCallingHandlers(expr, message = handler),
      warning = withCallingHandlers(expr, warning = handler)
    )
    switch(
      condition, 
      message = list(value = val, text = x, type = "message"),
      warning = list(value = val, text = x, type = "warning")
    )
  }
}

#' @export
#' @rdname capture_condition
capture_message <- cc_generator("message")

#' @export
#' @rdname capture_condition
capture_warning <- cc_generator("warning")

#' capture condition
#' 
#' @name capture_condition
#' @keywords internal
#' @examples
#' foom <- function(x) {
#'   message("its too bad")
#'   return(x)
#' }
#' capture_message(foom(4))
#' 
#' foow <- function(x) {
#'   warning("its too bad")
#'   return(x)
#' }
#' capture_warning(foow(4))
NULL
