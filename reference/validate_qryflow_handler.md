# Ensure correct handler structure

This function checks that the passed object is a function and contains
the arguments "chunk", "con, and "..." - in that order. This is to help
ensure users only register valid handlers.

## Usage

``` r
validate_qryflow_handler(handler)
```

## Arguments

- handler:

  object to check

## Value

Logical. Generates an error if the object does not pass all the
criteria.

## See also

[`validate_qryflow_parser()`](https://christian-million.github.io/qryflow/reference/validate_qryflow_parser.md)
for the parser equivalent.

## Examples

``` r
custom_func <- function(chunk, con, ...){

  # Parsing Code Goes Here

}

validate_qryflow_handler(custom_func)
```
