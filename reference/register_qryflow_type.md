# Register custom chunk types

Use this function to register a custom chunk type with qryflow

## Usage

``` r
register_qryflow_type(type, handler, overwrite = FALSE)
```

## Arguments

- type:

  Character indicating the chunk type (e.g., "exec", "query")

- handler:

  A function to execute the SQL associated with the type. Must accept
  arguments "chunk", "con", and "...".

- overwrite:

  Logical. Overwrite existing handler, if exists?

## Value

Logical. Indicating whether types were successfully registered.

## Details

To avoid manually registering your custom type each session, consider
adding the registration code to your `.Rprofile` or creating a package
that leverages [`.onLoad()`](https://rdrr.io/r/base/ns-hooks.html)

## Examples

``` r
# Create custom handler #####
custom_handler <- function(con, chunk, ...){
  # Custom execution code will go here...
  # return(result)
}

register_qryflow_type("query-send", custom_handler, overwrite = TRUE)
#> [1] TRUE
```
