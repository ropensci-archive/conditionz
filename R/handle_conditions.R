conditonz_env <- new.env()
# conditonz_env <- list()

#' handle conditions
#' 
#' @export
#' @param expr an expression
#' @param condition (character) one of "message" or "warning"
#' @param times (integer) max. times a condition should be thrown.
#' default: 1
#' @return whatever the `expr` returns
#' @examples
#' foo <- function(x) {
#'   message("you gave: ", x)
#'   return(x)
#' }
#' 
#' foo('a')
#' capture_message(foo('a'))
#' handle_conditions(foo('a'))
#' suppressMessages(handle_conditions(foo('a')))
#' handle_conditions(foo('a'), "message")
#' 
#' bar <- function(x) {
#'   for (i in x) message("you gave: ", i)
#'   return(x)
#' }
#' bar(1:5)
#' handle_conditions(bar(1:5))
handle_conditions <- function(expr, condition = "message", times = 1) {
  cond_keep <- ConditionKeeper$new(times = times)
  assign(cond_keep$get_id(), cond_keep, envir = conditonz_env)
  # cond_keep <- ConditionKeeper$new(times = times)
  on.exit(cond_keep$purge())
  res <- capture_x(condition)(expr)
  if (!is.null(res$text)) {
    txt <- res$text[[1]][condition]
    if (!cond_keep$thrown_enough(txt)) {
      cond_keep$add(txt)
      eval(parse(text=condition))(txt)
    }
  }
  return(res$value)
}


#' @export
#' @rdname handle_conditions
handle_messages <- function(expr) {
  handle_conditions(expr, "message")
}

#' @export
#' @rdname handle_conditions
handle_warnings <- function(expr) {
  handle_conditions(expr, "warning")
}

# helpers ------
capture_x <- function(x) {
  eval(parse(text = paste0("capture_", x)))
}
