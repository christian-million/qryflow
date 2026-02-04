# Check existence of a given parser in the registry

Checks whether the specified parser exists in the parser registry
environment.

## Usage

``` r
qryflow_parser_exists(type)
```

## Arguments

- type:

  chunk type to check (e.g., "query", "exec")

## Value

Logical. Does `type` exist in the parser registry?

## See also

[`qryflow_handler_exists()`](https://christian-million.github.io/qryflow/reference/qryflow_handler_exists.md)
for the handler equivalent.

## Examples

``` r
qryflow_parser_exists("query")
#> [1] TRUE
```
