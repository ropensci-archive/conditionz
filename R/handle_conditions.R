conditonz_env <- new.env()

#' Handle conditions
#' 
#' @export
#' @param expr an expression
#' @param condition (character) one of "message" or "warning"
#' @param times (integer) max. times a condition should be thrown.
#' default: 1
#' @return whatever the `expr` returns
#' @details Uses [ConditionKeeper] internally
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
#' 
#' handle_messages(foo('a'))
#' 
#' hello <- function(x) {
#'   warning("you gave: ", x)
#'   return(x)
#' }
#' handle_warnings(hello('a'))
#' 
#' # code block
#' handle_warnings({
#'   as.numeric(letters[1:3])
#'   as.numeric(letters[4:6])
#'   as.numeric(letters[7:9])
#' })
handle_conditions <- function(expr, condition = "message", times = 1) {
  if (!condition %in% c("message", "warning")) {
    stop("'condition' must be one of 'message' or 'warning'", 
      call. = FALSE)
  }
  cond_keep <- ConditionKeeper$new(times = times, condition = condition)
  assign(cond_keep$get_id(), cond_keep, envir = conditonz_env)
  on.exit(cond_keep$purge())
  res <- capture_x(condition)(expr)
  if (!is.null(res$text)) {
    txt <- res$text[[1]][['message']]
    if (!cond_keep$thrown_enough(txt)) {
      cond_keep$add(txt)
      switch(
        condition,
        message = eval(parse(text=condition))(txt),
        warning = eval(parse(text=condition))(txt, call. = FALSE)
      )
    }
  }
  return(res$value)
}


#' @export
#' @rdname handle_conditions
handle_messages <- function(expr, times = 1) {
  handle_conditions(expr, "message", times = times)
}

#' @export
#' @rdname handle_conditions
handle_warnings <- function(expr, times = 1) {
  handle_conditions(expr, "warning", times = times)
}

# helpers ------
capture_x <- function(x) {
  eval(parse(text = paste0("capture_", x)))
}
