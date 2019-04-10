#' ConditionKeeper
#' 
#' @export
#' @param times (integer) number of times to throw condition. required.
#' default: 1
#' @param condition (character) which condition, one of "message" (default) or
#' "warning"
#' @format NULL
#' @usage NULL
#' @details
#' **Methods**
#'
#' - `add(x)` - add a condition to internal storage
#' - `remove()` - remove the first condition from internal storage; returns that
#' condition so you know what you removed
#' - `purge()` - removes all conditions
#' - `thrown_already(x)` - (return: logical) has the condition been thrown
#' already?
#' - `not_thrown_yet(x)` - (return: logical) has the condition NOT been thrown
#' yet?
#' - `thrown_times(x)` - (return: numeric) number of times the condition
#' has been thrown
#' - `thrown_enough(x)` - (return: logical) has the condition been thrown
#' enough? "enough" being: thrown number of times equal to what you
#' specified in the `times` parameter
#' - `get_id()` - get the internal ID for the ConditionKeeper object
#' - `handle_conditions(expr)` - pass a code block or function and handle
#' conditions within it
#' 
#' @seealso [handle_conditions()]
#'
#' @examples
#' x <- ConditionKeeper$new(times = 4)
#' x
#' x$get_id()
#' x$add("one")
#' x$add("two")
#' x
#' x$thrown_already("one")
#' x$thrown_already("bears")
#' x$not_thrown_yet("bears")
#' 
#' x$add("two")
#' x$add("two")
#' x$add("two")
#' x$thrown_times("two")
#' x$thrown_enough("two")
#' x$thrown_enough("one")
#' 
#' foo <- function(x) {
#'   message("you gave: ", x)
#'   return(x)
#' }
#' foo('a')
#' x$handle_conditions(foo('a'))
#' 
#' x <- ConditionKeeper$new(times = 4, condition = "warning")
#' x
#' x$add("one")
#' x$add("two")
#' x
ConditionKeeper <- R6::R6Class("ConditionKeeper",
  public = list(
    bucket = NULL,
    times = 1,
    condition = "message",
    
    initialize = function(times = 1, condition = "message") {
      assert(times, c('numeric', 'integer'))
      self$times <- times

      assert(condition, "character")
      if (!condition %in% c("message", "warning")) {
        stop("'condition' must be one of 'message' or 'warning'", 
          call. = FALSE)
      }
      self$condition <- condition

      # assign unique id to the class object
      private$id <- uuid::UUIDgenerate()
    },
    
    print = function(x, ...) {
      cat('ConditionKeeper', sep = "\n")
      cat(paste0(' id: ', private$id), sep = "\n")
      cat(paste0(' times: ', self$times), sep = "\n")
      cat(paste0(' messages: ', length(self$bucket)))
      if (length(self$bucket) > 0) {
        cat("\n")
        for (i in self$bucket) {
          cat(paste0("  ", substring(i, 1, 50)))
        }
      }
    },
    add = function(x) {
      self$bucket <- c(self$bucket, x)
      invisible(self)
    },
    remove = function() {
      if (length(self$bucket) == 0) return(NULL)
      head <- self$bucket[[1]]
      self$bucket <- self$bucket[-1]
      head
    },
    purge = function() {
      self$bucket <- NULL
    },
    thrown_already = function(x) {
      x %in% self$bucket
    },
    not_thrown_yet = function(x) {
      !self$thrown_already(x)
    },
    thrown_times = function(x) {
      length(self$bucket[self$bucket %in% x])
    },
    thrown_enough = function(x) {
      self$thrown_times(x) >= self$times
    },
    get_id = function() private$id,

    handle_conditions = function(expr) {
      res <- capture_x(self$condition)(expr)
      if (!is.null(res$text)) {
        txt <- res$text[[1]][['message']]
        if (!self$thrown_enough(txt)) {
          self$add(txt)
          switch(
            self$condition,
            message = eval(parse(text=self$condition))(txt),
            warning = eval(parse(text=self$condition))(txt, call. = FALSE)
          )
        }
      }
      return(res$value)
    }
  ),

  private = list(
    id = NULL
  )
)
