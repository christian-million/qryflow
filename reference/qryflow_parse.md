# Parse a SQL workflow into tagged chunks

`qryflow_parse()` reads a SQL workflow file or character vector and
parses it into discrete tagged chunks based on `@query`, `@exec`, and
other custom markers.

## Usage

``` r
qryflow_parse(sql, default_type = "query")
```

## Arguments

- sql:

  A file path to a SQL workflow file, or a character vector containing
  SQL lines.

- default_type:

  The default chunk type (defaults to "query")

## Value

An object of class `qryflow_workflow`, which is a structured list of SQL
chunks and metadata.

## Details

This function is used internally by
[`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md),
but can also be used directly to preprocess or inspect the structure of
a SQL workflow.

## See also

[`qryflow()`](https://christian-million.github.io/qryflow/reference/qryflow.md),
[`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md),
[`qryflow_execute()`](https://christian-million.github.io/qryflow/reference/qryflow_execute.md)

## Examples

``` r
filepath <- example_sql_path("mtcars.sql")

parsed <- qryflow_parse(filepath)
```
