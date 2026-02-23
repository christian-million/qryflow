# Extract tagged metadata from a SQL chunk

`extract_all_tags()` scans SQL for specially formatted comment tags
(e.g., `-- @tag: value`) and returns them as a named list. This is
exported with the intent to be useful for users extending `qryflow`.
It's typically used against a single SQL chunk, such as one parsed from
a `.sql` file.

## Usage

``` r
extract_all_tags(text)

subset_tags(tags, keep, negate = FALSE)
```

## Arguments

- text:

  A character vector of SQL lines or a file path to a SQL script.

- tags:

  A named list of tags, typically from `extract_all_tags()`. Used in
  `subset_tags()`.

- keep:

  A character vector of tag names to keep or exclude in `subset_tags()`.

- negate:

  Logical; if `TRUE`, `subset_tags()` returns all tags except those
  listed in `keep`.

## Value

- `extract_all_tags()`: A named list of all tags found in the SQL chunk.

- `subset_tags()`: A filtered named list of tags or `NULL` if none
  remain.

## See also

[`qryflow_parse()`](https://christian-million.github.io/qryflow/reference/qryflow_parse.md),
[`ls_qryflow_types()`](https://christian-million.github.io/qryflow/reference/ls_qryflow_types.md)

## Examples

``` r
filepath <- example_sql_path('mtcars.sql')
parsed <- qryflow_parse(filepath)

chunk <- parsed[[1]]
tags <- extract_all_tags(chunk$sql)
subset_tags(tags, keep = c("query"))
#> list()
```
