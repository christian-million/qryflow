# Ensure correct parser structure

This function checks that the passed object is a function and contains
the arguments "x" and "..." - in that order. This is to help ensure
users only register valid parsers.

## Usage

``` r
validate_qryflow_parser(parser)
```

## Arguments

- parser:

  object to check

## Value

Logical. Generates an error if the object does not pass all the
criteria.

## See also

[`validate_qryflow_handler()`](https://christian-million.github.io/qryflow/reference/validate_qryflow_handler.md)
for the handler equivalent.

## Examples

``` r
custom_func <- function(x, ...){

  # Parsing Code Goes Here

}
validate_qryflow_parser(custom_func)
```
