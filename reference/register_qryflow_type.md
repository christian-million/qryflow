# Register custom chunk types

Use these functions to register the parsers and handlers associated with
custom types. `register_qryflow_type` is a wrapper around both
`register_qryflow_parser` and `register_qryflow_handler`.

## Usage

``` r
register_qryflow_type(type, parser, handler, overwrite = FALSE)

register_qryflow_parser(type, parser, overwrite = FALSE)

register_qryflow_handler(type, handler, overwrite = FALSE)
```

## Arguments

- type:

  Character indicating the chunk type (e.g., "exec", "query")

- parser:

  A function to parse the SQL associated with the type. Must accept
  arguments "x" and "..." and return a `qryflow_chunk` object.

- handler:

  A function to execute the SQL associated with the type. Must accept
  arguments "chunk", "con", and "...".

- overwrite:

  Logical. Overwrite existing parser and handler, if exists?

## Value

Logical. Indicating whether types were successfully registered.

## Details

To avoid manually registering your custom type each session, consider
adding the registration code to your `.Rprofile` or creating a package
that leverages [`.onLoad()`](https://rdrr.io/r/base/ns-hooks.html)

## Examples

``` r
# Create custom parser #####
custom_parser <- function(x, ...){
  # Custom parsing code will go here

  # new_qryflow_chunk(type = "custom", name = name, sql = sql_txt, tags = tags)
}

# Create custom handler #####
custom_handler <- function(con, chunk, ...){
  # Custom execution code will go here...
  # return(result)
}

# Register Separately #####
register_qryflow_parser("custom", custom_parser, overwrite = TRUE)
#> [1] TRUE

register_qryflow_handler("custom", custom_handler, overwrite = TRUE)
#> [1] TRUE


# Register Simultaneously #####
register_qryflow_type("query-send", custom_parser, custom_handler, overwrite = TRUE)
#> [1] TRUE
```
