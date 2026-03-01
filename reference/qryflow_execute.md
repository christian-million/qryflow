# Execute a parsed qryflow SQL workflow

`qryflow_execute()` takes a `qryflow` object (as returned by
[`qryflow_parse()`](https://christian-million.github.io/qryflow/reference/qryflow_parse.md)),
executes each chunk (e.g., `@query`, `@exec`), and collects the results
and timing metadata.

This function is used internally by
[`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md),
but can be called directly in concert with
[`qryflow_parse()`](https://christian-million.github.io/qryflow/reference/qryflow_parse.md)
if you want to manually control parsing and execution.

## Usage

``` r
qryflow_execute(
  con,
  x,
  ...,
  on_error = c("stop", "warn", "collect"),
  verbose = getOption("qryflow.verbose", FALSE)
)
```

## Arguments

- con:

  A database connection from
  [`DBI::dbConnect()`](https://dbi.r-dbi.org/reference/dbConnect.html)

- x:

  A `qryflow` object, typically created by
  [`qryflow_parse()`](https://christian-million.github.io/qryflow/reference/qryflow_parse.md)

- ...:

  Reserved for future use

- on_error:

  Controls behaviour when a chunk fails during execution. One of
  `"stop"` (default), `"warn"`, or `"collect"`. `"stop"` halts execution
  immediately and returns the partially executed workflow. `"warn"`
  records the error in the chunk's `meta`, signaling immediately.
  `"collect"` gathers all errors from across all chunks and reports them
  at the end.

- verbose:

  Logical. If `TRUE`, emits a message before each chunk identifying its
  name and type, and prints a summary on completion reporting total
  chunks run, successes, errors, and elapsed time. Defaults to `FALSE`.
  The global default can be set with `options(qryflow.verbose = TRUE)`.

## Value

An object of class `qryflow`, containing executed chunks with results
and a `meta` attribute that includes timing and source information.

## See also

[`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md),
[`qryflow_parse()`](https://christian-million.github.io/qryflow/reference/qryflow_parse.md)

## Examples

``` r
con <- example_db_connect(mtcars)

filepath <- example_sql_path("mtcars.sql")

parsed <- qryflow_parse(filepath)

executed <- qryflow_execute(con, parsed)

DBI::dbDisconnect(con)
```
