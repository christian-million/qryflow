# Extending qryflow Functionality

``` r
library(qryflow)
```

## Overview

`qryflow` was designed to be easily extended and allows users to define
custom chunk types. This vignette provides relevant background knowledge
on how `qryflow` works under the hood, then walks through how to create
and register custom chunk types.

This vignette assumes the knowledge found in the “Getting Started”
(`vignette("getting-started", package = "qryflow")`) and “Advanced
Usage”
([`vignette("advanced-qryflow", package = "qryflow")`](https://christian-million.github.io/qryflow/articles/advanced-qryflow.md))
vignettes.

## Big Picture: How `qryflow` Works

When you run a SQL script using `qryflow`, the process follows these
steps:

1.  Split the SQL script into chunks using tagged comments (e.g.,
    `-- @query: name`)

2.  Parse each chunk, capturing type, name, and other tags

3.  Execute each chunk using a **type-specific handler**

To support a new chunk type, you’ll need to:

- **Create a handler** — which defines how to execute the chunk and
  return results.

- **Register** your new type with `qryflow` so the package knows how to
  process it.

## Creating Handlers

Each chunk type needs to have an associated handler. This section
outlines what arguments the custom handler functions need to accept,
what operations it should perform, and what results it should return.

Handlers accepts both a `qryflow_chunk` object and a database connection
object (e.g.,
[`DBI::dbConnect`](https://dbi.r-dbi.org/reference/dbConnect.html)).
They should execute the SQL as appropriate and then return the result:

This is the handler for the “exec” type:

``` r
qryflow_exec_handler <- function(con, chunk, ...) {
  
  # Pass the SQL of the chunk to desired execution strategy
  result <- DBI::dbExecute(con, chunk$sql, ...)

  # Return the result
  result
}
```

After a custom handler has been created, it needs to be registered.

### Validate the Handler

`qryflow` provides
[`validate_qryflow_handler()`](https://christian-million.github.io/qryflow/reference/validate_qryflow_handler.md)
to test whether the handler function meets specifications. An error will
occur if:

- The object is not a function

- The formal arguments are not included

- The formal arguments are not in the right order

``` r
validate_qryflow_handler(qryflow_exec_handler)
```

Note: This does not test that the code within your function is correct
nor does it test what output each function is expected to produce.

## How the Registry Works

`qryflow` maintains and internal environment called `.qryflow_handlers`
to store registered chunk handlers.

When the package is loaded, default types like “`query`” and “`exec`”
are automatically registered. You can register additional types using:

``` r
register_qryflow_type("custom", my_custom_handler_func, overwrite = TRUE)
```

This will validate the handler before registering in the internal
environment.

We can access what types are registered:

``` r
ls_qryflow_types()
```

Custom types must be re-registered each session. To make them
persistent, add registration calls to your `.Rprofile` (see: [Managing R
Startup](https://docs.posit.co/ide/user/ide/guide/environments/r/managing-r.html)),
or create a small package with an `.onLoad()` hook (see: [R Packages
(2e)](https://r-pkgs.org/code.html#sec-code-onLoad-onAttach)).

## Toy Example: Create `query-send` Chunk Type

This example shows how to implement a new chunk type that’s similar to
`exec` and `query`. We will create a new type, called `query-send` that
works like `query` except calls
[`DBI::dbSendQuery`](https://dbi.r-dbi.org/reference/dbSendQuery.html)
instead of
[`DBI::dbGetQuery`](https://dbi.r-dbi.org/reference/dbGetQuery.html).

First, create the handler:

``` r
query_send_handler <- function(con, chunk, ...) {
  res <- DBI::dbSendQuery(con, chunk$sql, ...)

  results <- DBI::dbFetch(res)

  DBI::dbClearResult(res)

  results
}
```

Validate it by hand, if you’d like:

``` r
validate_qryflow_handler(query_send_handler)
```

Then, register it:

``` r
register_qryflow_type(
  "query-send",
  handler = query_send_handler,
  overwrite = TRUE
)
#> [1] TRUE
```

Check that it registered properly:

``` r
ls_qryflow_types()
#> [1] "exec"       "query"      "query-send"
```

And test it out on some SQL:

``` r
# Creates an in-memory sqlite database and populates it with an mtcars table, named "mtcars"
con <- example_db_connect(mtcars)

# Create
sql <- "
-- @query-send: df_mtcars
SELECT *
FROM mtcars;
"

results <- qryflow(con, sql)

head(results)
#>    mpg cyl disp  hp drat    wt  qsec vs am gear carb
#> 1 21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
#> 2 21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
#> 3 22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
#> 4 21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
#> 5 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
#> 6 18.1   6  225 105 2.76 3.460 20.22  1  0    3    1
```
