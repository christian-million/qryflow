# Check existence of a given handler in the registry

Checks whether the specified handler exists in the handler registry
environment.

## Usage

``` r
qryflow_handler_exists(type)
```

## Arguments

- type:

  chunk type to check (e.g., "query", "exec")

## Value

Logical. Does `type` exist in the handler registry?

## See also

[`qryflow_parser_exists()`](https://christian-million.github.io/qryflow/reference/qryflow_parser_exists.md)
for the parser equivalent.

## Examples

``` r
qryflow_handler_exists("query")
#> [1] TRUE
```
