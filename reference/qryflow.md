# Run a multi-step SQL workflow and return query results

`qryflow()` is high level convenience function. It executes a SQL
workflow defined in a tagged `.sql` script or character string and
returns query results as R objects.

The SQL script can contain multiple-steps (chunks), each tagged with
`@query` or `@exec`. Query results are captured and returned as a named
list, where names correspond to the `@query` tags.

## Usage

``` r
qryflow(
  con,
  sql,
  ...,
  on_error = c("stop", "warn", "collect"),
  verbose = getOption("qryflow.verbose", FALSE),
  simplify = TRUE,
  default_type = getOption("qryflow.default_type", "query")
)
```

## Arguments

- con:

  A database connection from
  [`DBI::dbConnect()`](https://dbi.r-dbi.org/reference/dbConnect.html)

- sql:

  A file path to a `.sql` workflow or a character string containing SQL
  code.

- ...:

  Additional arguments passed to
  [`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md)
  or
  [`qryflow_results()`](https://christian-million.github.io/qryflow/reference/qryflow_results.md).

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

- simplify:

  Logical; if `TRUE` (default), a list of length 1 is simplified to the
  single result object.

- default_type:

  The default chunk type (defaults to "query"). The global default can
  be set with `options(qryflow.default_type = 'query')`.

## Value

A named list of query results, or a single result if `simplify = TRUE`
and only one chunk exists.

## Details

This is a wrapper around the combination of
[`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md),
which always provides a list of results and metadata, and
[`qryflow_results()`](https://christian-million.github.io/qryflow/reference/qryflow_results.md),
which filters the output of
[`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md)
to only include the results of the SQL.

## See also

[`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md),
[`qryflow_results()`](https://christian-million.github.io/qryflow/reference/qryflow_results.md)

## Examples

``` r
con <- example_db_connect(mtcars)
filepath <- example_sql_path("mtcars.sql")

results <- qryflow(con, filepath)

head(results$df_mtcars)
#>    mpg cyl disp  hp drat    wt  qsec vs am gear carb
#> 1 21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
#> 2 21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
#> 3 22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
#> 4 21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
#> 5 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
#> 6 18.1   6  225 105 2.76 3.460 20.22  1  0    3    1

DBI::dbDisconnect(con)
```
