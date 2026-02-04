# Get path to qryflow example SQL scripts

qryflow provides example SQL scripts in its `inst/sql` directory. Use
this function to retrieve the path to an example script. This function
is intended to facilitate examples, vignettes, and package tests.

## Usage

``` r
example_sql_path(path = "mtcars.sql")
```

## Arguments

- path:

  filename of the example script.

## Value

path to example SQL script

## Examples

``` r
path <- example_sql_path("mtcars.sql")

file.exists(path)
#> [1] TRUE
```
