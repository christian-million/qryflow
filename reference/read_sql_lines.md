# Standardizes lines read from string, character vector, or file

This is a generic function to ensure lines read from a file, a single
character vector, or already parsed lines return the same format. This
helps avoid re-reading entire texts by enabling already read lines to
pass easily.

This is useful for folks who may want to extend qryflow.

## Usage

``` r
read_sql_lines(x)
```

## Arguments

- x:

  a filepath or character vector containing SQL

## Value

A `qryflow_sql` object (inherits from character) with a length equal to
the number of lines read

## Examples

``` r
# From a file #####
path <- example_sql_path()
read_sql_lines(path)
#> <qryflow_sql>
#> -- @exec: drop_cyl_6
#> DROP TABLE IF EXISTS cyl_6;
#> 
#> -- @exec: prep_cyl_6
#> CREATE TABLE cyl_6 AS
#> SELECT *
#> FROM mtcars
#> WHERE cyl = 6;
#> 
#> -- @query: df_mtcars
#> SELECT *
#> FROM mtcars;
#> 
#> -- @query: df_cyl_6
#> SELECT *
#> FROM cyl_6;

# From a single string #####
sql <- "SELECT *
FROM mtcars;"
read_sql_lines(sql)
#> <qryflow_sql>
#> SELECT *
#> FROM mtcars;

# From a character #####
lines <- c("SELECT *", "FROM mtcars;")
read_sql_lines(lines)
#> <qryflow_sql>
#> SELECT *
#> FROM mtcars;
```
