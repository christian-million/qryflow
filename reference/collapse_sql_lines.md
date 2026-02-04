# Collapse SQL lines into single character

A thin wrapper around `paste0(x, collapse = '\\n')` to standardize the
way qryflow collapses SQL lines.

## Usage

``` r
collapse_sql_lines(x)
```

## Arguments

- x:

  character vector of SQL lines

## Value

a character vector of length 1

## Examples

``` r
path <- example_sql_path()

lines <- read_sql_lines(path)

sql <- collapse_sql_lines(lines)
```
