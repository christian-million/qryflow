# Extract results from a `qryflow_workflow` object

`qryflow_results()` retrieves the query results from a list returned by
[`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md),
typically one that includes parsed and executed SQL chunks.

## Usage

``` r
qryflow_results(x, ..., simplify = FALSE)
```

## Arguments

- x:

  Results from
  [`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md),
  usually containing a mixture of `qryflow_chunk` objects.

- ...:

  Reserved for future use.

- simplify:

  Logical; if `TRUE`, simplifies the result to a single object if only
  one query chunk is present. Defaults to `FALSE`.

## Value

A named list of query results, or a single result object if
`simplify = TRUE` and only one result is present.

## See also

[`qryflow()`](https://christian-million.github.io/qryflow/reference/qryflow.md),
[`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md)

## Examples

``` r
con <- example_db_connect(mtcars)

filepath <- example_sql_path("mtcars.sql")

obj <- qryflow_run(filepath, con)

results <- qryflow_results(obj)

DBI::dbDisconnect(con)
```
