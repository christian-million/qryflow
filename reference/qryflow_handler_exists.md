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

## Examples

``` r
qryflow_handler_exists("query")
#> [1] TRUE
```
