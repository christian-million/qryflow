# Detect the presence of a properly structured tagline

Checks whether a specially structured comment line if formatted in the
way that qryflow expects.

## Usage

``` r
is_tag_line(line)
```

## Arguments

- line:

  A character vector to check. It is a vectorized function.

## Value

Logical. Indicating whether each line matches tag specification.

## Details

Tag lines should look like this: `-- @key: value`

- Begins with an inline comment (`--`)

- An `@` precedes a tag type (e.g., `type`, `name`, `query`, `exec`) and
  is followed by a colon (`:`)

- A value is provided

## Examples

``` r
a <- "-- @query: df_mtcars"
b <- "-- @exec: prep_tbl"
c <- "-- @type: query"

lines <- c(a, b, c)

is_tag_line(lines)
#> [1] TRUE TRUE TRUE
```
