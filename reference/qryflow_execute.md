# Execute a parsed qryflow SQL workflow

`qryflow_execute()` takes a parsed workflow object (as returned by
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
qryflow_execute(x, con, ..., source = NULL)
```

## Arguments

- x:

  A parsed qryflow workflow object, typically created by
  [`qryflow_parse()`](https://christian-million.github.io/qryflow/reference/qryflow_parse.md)

- con:

  A database connection from
  [`DBI::dbConnect()`](https://dbi.r-dbi.org/reference/dbConnect.html)

- ...:

  Reserved for future use.

- source:

  Optional; a character string indicating the source SQL to include in
  metadata.

## Value

An object of class `qryflow_result`, containing executed chunks with
results and a `meta` field that includes timing and source information.

## See also

[`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md),
[`qryflow_parse()`](https://christian-million.github.io/qryflow/reference/qryflow_parse.md)

## Examples

``` r
con <- example_db_connect(mtcars)

filepath <- example_sql_path("mtcars.sql")

parsed <- qryflow_parse(filepath)

executed <- qryflow_execute(parsed, con, source = filepath)

DBI::dbDisconnect(con)
```
