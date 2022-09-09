conditionz
==========



[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-check](https://github.com/ropensci/conditionz/workflows/R-check/badge.svg)](https://github.com/ropensci/conditionz/actions?query=workflow%3AR-check)
[![codecov.io](https://codecov.io/github/ropensci/conditionz/coverage.svg?branch=master)](https://codecov.io/github/ropensci/conditionz?branch=master)
[![rstudio mirror downloads](https://cranlogs.r-pkg.org/badges/conditionz)](https://github.com/r-hub/cranlogs.app)
[![cran version](https://www.r-pkg.org/badges/version/conditionz)](https://cran.r-project.org/package=conditionz)

control how many times conditions are thrown

docs: https://ropensci.github.io/conditionz/

Package API:

 - `handle_messages`
 - `handle_conditions`
 - `ConditionKeeper`
 - `handle_warnings`
 - `capture_message`
 - `capture_warning`

Use cases for `conditionz` functions:

- `ConditionKeeper` is what you want to use if you want to keep track of conditions inside a
function being applied many times, either in a for loop or lapply style fashion.
- `handle_conditions`/`handle_messages`/`handle_warnings` is what you want to use if the multiple
conditions are happening within a single function or code block
- `capture_message`/`capture_warning` are meant for capturing messages/warnings into a useable
list

## Installation

The CRAN version:


```r
install.packages("conditionz")
```

Or the development version:


```r
remotes::install_github("ropensci/conditionz")
```


```r
library("conditionz")
```

## ConditionKeeper

`ConditionKeeper` is the internal R6 class that handles keeping track of
conditions and lets us determine if conditions have been encountered,
how many times, etc.


```r
x <- ConditionKeeper$new(times = 4)
x
#> ConditionKeeper
#>  id: 98e020c2-e805-4da0-a369-d1939dc7c998
#>  times: 4
#>  messages: 0
x$get_id()
#> [1] "98e020c2-e805-4da0-a369-d1939dc7c998"
x$add("one")
x$add("two")
x
#> ConditionKeeper
#>  id: 98e020c2-e805-4da0-a369-d1939dc7c998
#>  times: 4
#>  messages: 2
#>   one  two
x$thrown_already("one")
#> [1] TRUE
x$thrown_already("bears")
#> [1] FALSE
x$not_thrown_yet("bears")
#> [1] TRUE

x$add("two")
x$add("two")
x$add("two")
x$thrown_times("two")
#> [1] 4
x$thrown_enough("two")
#> [1] TRUE
x$thrown_enough("one")
#> [1] FALSE
```

## basic usage

A simple function that throws messages


```r
squared <- function(x) {
  stopifnot(is.numeric(x))
  y <- x^2
  if (y > 20) message("woops, > than 20! check your numbers")
  return(y)
}
foo <- function(x) {
  vapply(x, function(z) squared(z), numeric(1))
}
bar <- function(x, times = 1) {
  y <- ConditionKeeper$new(times = times)
  on.exit(y$purge())
  vapply(x, function(z) y$handle_conditions(squared(z)), numeric(1))
}
```

Running the function normally throws many messages


```r
foo(1:10)
#> woops, > than 20! check your numbers
#> woops, > than 20! check your numbers
#> woops, > than 20! check your numbers
#> woops, > than 20! check your numbers
#> woops, > than 20! check your numbers
#> woops, > than 20! check your numbers
#>  [1]   1   4   9  16  25  36  49  64  81 100
```

Using in `ConditionKeeper` allows you to control how many messages
are thrown


```r
bar(x = 1:10)
#> woops, > than 20! check your numbers
#>  [1]   1   4   9  16  25  36  49  64  81 100
```


```r
bar(1:10, times = 3)
#> woops, > than 20! check your numbers
#> 
#> woops, > than 20! check your numbers
#> 
#> woops, > than 20! check your numbers
#>  [1]   1   4   9  16  25  36  49  64  81 100
```

## benchmark

definitely need to work on performance


```r
library(microbenchmark)
microbenchmark::microbenchmark(
  normal = suppressMessages(foo(1:10)),
  with_conditionz = suppressMessages(bar(1:10)),
  times = 100
)
#> Unit: microseconds
#>             expr      min        lq     mean    median       uq      max neval
#>           normal  902.391  939.6685 1071.314  957.6225 1076.281 3251.181   100
#>  with_conditionz 1719.505 1746.8675 1927.367 1788.8385 1993.597 4090.570   100
```

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/conditionz/issues).
* License: MIT
* Get citation information for `conditionz` in R doing `citation(package = 'conditionz')`
* Please note that this package is released with a [Contributor Code of Conduct](https://ropensci.org/code-of-conduct/). By contributing to this project, you agree to abide by its terms.

[![rofooter](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org)
