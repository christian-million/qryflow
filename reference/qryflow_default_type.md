# Access the default qryflow chunk type

Retrieves the value from the option `qryflow.default.type`, if set.
Otherwise returns "query", which is the officially supported default
type. If any value is supplied to the function, it returns that value.

## Usage

``` r
qryflow_default_type(type = getOption("qryflow.default.type", "query"))
```

## Arguments

- type:

  Optional. The type you want to return.

## Value

Character. If set, result from `qryflow.default.type` option, otherwise
"query" or value passed to `type`

## Examples

``` r
x <- getOption("qryflow.default.type", "query")

y <- qryflow_default_type()

identical(x, y)
#> [1] TRUE
```
