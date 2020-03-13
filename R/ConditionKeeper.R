#' @title ConditionKeeper
#' @description R6 class with methods for handling conditions
#' @export 
#' @seealso [handle_conditions()]
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
    #' @field bucket list holding conditions
    bucket = NULL,
    #' @field times number of times
    times = 1,
    #' @field condition (character) type of condition, message or warning
    condition = "message",
    
    #' @description Create a new `ConditionKeeper` object
    #' @param times (integer) number of times to throw condition. required.
    #' default: 1
    #' @param condition (character) which condition, one of "message" (default)
    #' or "warning"
    #' @return A new `ConditionKeeper` object
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
    
    #' @description print method for the `ConditionKeeper` class
    #' @param x self
    #' @param ... ignored
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
    #' @description add a condition to internal storage
    #' @param x a condition
    #' @return self
    add = function(x) {
      self$bucket <- c(self$bucket, x)
      invisible(self)
    },
    #' @description remove the first condition from internal storage;
    #' returns that condition so you know what you removed
    #' @return the condition removed
    remove = function() {
      if (length(self$bucket) == 0) return(NULL)
      head <- self$bucket[[1]]
      self$bucket <- self$bucket[-1]
      head
    },
    #' @description removes all conditions
    #' @return NULL
    purge = function() {
      self$bucket <- NULL
    },
    #' @description has the condition been thrown already?
    #' @param x a condition
    #' @return logical
    thrown_already = function(x) {
      x %in% self$bucket
    },
    #' @description has the condition NOT been thrown yet?
    #' @param x a condition
    #' @return logical
    not_thrown_yet = function(x) {
      !self$thrown_already(x)
    },
    #' @description number of times the condition has been thrown
    #' @param x a condition
    #' @return numeric
    thrown_times = function(x) {
      length(self$bucket[self$bucket %in% x])
    },
    #' @description has the condition been thrown enough? "enough" being:
    #' thrown number of times equal to what you specified in the `times`
    #' parameter
    #' @param x a condition
    #' @return logical
    thrown_enough = function(x) {
      self$thrown_times(x) >= self$times
    },
    #' @description get the internal ID for the ConditionKeeper object
    #' @return a UUID (character)
    get_id = function() private$id,
    #' @description pass a code block or function and handle conditions
    #' within it
    #' @param expr an expression 
    #' @return the result of calling the expression
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
