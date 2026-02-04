# Extract tagged metadata from a SQL chunk

`extract_all_tags()` scans SQL for specially formatted comment tags
(e.g., `-- @tag: value`) and returns them as a named list. This is
exported with the intent to be useful for users extending `qryflow`.
It's typically used against a single SQL chunk, such as one parsed from
a `.sql` file.

Additional helpers like `extract_tag()`, `extract_name()`, and
`extract_type()` provide convenient access to specific tag values.
`subset_tags()` lets you filter or exclude tags by name.

## Usage

``` r
extract_all_tags(text, tag_pattern = "^\\s*--\\s*@([^:]+):\\s*(.*)$")

extract_tag(text, tag)

extract_name(text)

extract_type(text)

subset_tags(tags, keep, negate = FALSE)
```

## Arguments

- text:

  A character vector of SQL lines or a file path to a SQL script.

- tag_pattern:

  A regular expression for extracting tags. Defaults to lines in the
  form `-- @tag: value`.

- tag:

  A character string naming the tag to extract (used in
  `extract_tag()`).

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

- `extract_tag()`, `extract_name()`, `extract_type()`: A single tag
  value (character or `NULL`).

- `subset_tags()`: A filtered named list of tags or `NULL` if none
  remain.

## Details

The formal type of a qryflow SQL chunk is determined by `extract_type()`
using a prioritized approach:

1.  If the chunk includes an explicit `-- @type:` tag, its value is used
    directly as the chunk type.

2.  If the `@type:` tag is absent, `qryflow` searches for other tags
    (e.g., `@query:`, `@exec:`) that correspond to registered chunk
    types through
    [`ls_qryflow_types()`](https://christian-million.github.io/qryflow/reference/ls_qryflow_types.md).
    The first matching tag found defines the chunk type.

3.  If neither an explicit `@type:` tag nor any recognized tag is
    present, the chunk type falls back to the default type returned by
    [`qryflow_default_type()`](https://christian-million.github.io/qryflow/reference/qryflow_default_type.md).

## See also

[`qryflow_parse()`](https://christian-million.github.io/qryflow/reference/qryflow_parse.md),
[`ls_qryflow_types()`](https://christian-million.github.io/qryflow/reference/ls_qryflow_types.md),
[`qryflow_default_type()`](https://christian-million.github.io/qryflow/reference/qryflow_default_type.md)

## Examples

``` r
filepath <- example_sql_path('mtcars.sql')
parsed <- qryflow_parse(filepath)

chunk <- parsed$chunks[[1]]
tags <- extract_all_tags(chunk$sql)

extract_name(chunk$sql)
#> NULL
extract_type(chunk$sql)
#> [1] "query"
subset_tags(tags, keep = c("query"))
#> list()
```
