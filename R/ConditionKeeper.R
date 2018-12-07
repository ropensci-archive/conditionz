#' ConditionKeeper
#' 
#' @export
#' @param times (integer) number of times to throw condition. required.
#' default: 1
#' @format NULL
#' @usage NULL
#' @details
#' **Methods**
#'
#' - `add()` - xx
#' - `remove()` - xx
#' - `purge()` - xx
#' - `thrown_already()` - xx
#' - `not_thrown_yet()` - xx
#' - `thrown_times()` - xx
#' - `thrown_enough()` - xx
#' - `get_id()` - xx
#' - `handle_conditions()` - xx
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
ConditionKeeper <- R6::R6Class("ConditionKeeper",
  public = list(
    bucket = NULL,
    times = 1,
    condition = "message",
    
    initialize = function(times = 1, condition = "message") {
      assert(times, c('numeric', 'integer'))
      self$times <- times

      assert(condition, "character")
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
      if (self$length() == 0) return(NULL)
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
        txt <- res$text[[1]][[self$condition]]
        if (!self$thrown_enough(txt)) {
          self$add(txt)
          eval(parse(text = self$condition))(txt)
        }
      }
      return(res$value)
    }
  ),

  private = list(
    id = NULL
  )
)
