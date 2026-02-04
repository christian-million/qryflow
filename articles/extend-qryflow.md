# Extending qryflow Functionality

``` r
library(qryflow)
```

## Overview

`qryflow` was designed to be easily extended and allows users to define
custom chunk types. This vignette provides relevant background knowledge
on how `qryflow` works under the hood, then walks through how to create
and register custom chunk types.

This vignette assumes the knowledge found in the “Getting Started”
(`vignette("getting-started", package = "qryflow")`) and “Advanced
Usage”
([`vignette("advanced-qryflow", package = "qryflow")`](https://christian-million.github.io/qryflow/articles/advanced-qryflow.md))
vignettes.

## Big Picture: How `qryflow` Works

When you run a SQL script using `qryflow`, the process follows these
steps:

1.  Split the SQL script into chunks using tagged comments (e.g.,
    `-- @query: name`)

2.  Identify the type of each chunk

3.  Parse each chunk into a structured object using a **type-specific
    parser**

4.  Execute each chunk using a **type-specific handler**

To support a new chunk type, you’ll need to:

- **Create a parser** — which converts a chunk of raw SQL into a
  structured `qryflow_chunk` object.

- **Create a handler** — which defines how to execute the chunk and
  return results.

- **Register** your new type with `qryflow` so the package knows how to
  process it.

## Creating Parsers and Handlers

Each chunk type needs to have an associated parser and an associated
handler. This section outlines what arguments the custom parser and
handler functions need to accept, what operations they should perform,
and what results they should return.

### Parsers

The parser accepts the unaltered SQL statement of the chunk and should
return a formal `qryflow_chunk` object. Parsers will only be executed on
a single chunk at a time. The `sqflow_chunk` object is essentially a
list in the form of:

``` r
list(
  type = type,
  name = name,
  sql = sql,
  tags = tags,
  results = results # Not populated until after execution
)
```

The parser must extract the type, name, main SQL statement, and any
additional tags. The package provides some helpers to do this. As an
example, here is what the “exec” type parser looks like, with
informative comments:

``` r
qryflow_exec_parser <- function(x, ...) {

  # Get a character vector containing each line
  lines <- read_sql_lines(x)

  # Identify any formal qryflow tags
  all_tags <- extract_all_tags(lines)

  # Check to see if an explicit name tag exists for the chunk
  name <- all_tags$name

  # If an explicit name tag doesn't exist, use the value from the "exec" tag
  # This is how aliases are implemented
  if(is.null(name)) {
    name <- all_tags[["exec"]]
  }

  # Find any additional tags beyond alias, name, or type
  tags <- subset_tags(all_tags, c("exec", "name", "type"), negate = TRUE)

  # Collapse the SQL into a single character
  sql_txt <- collapse_sql_lines(lines[!is_tag_line(lines)])

  # Return the structured object
  new_qryflow_chunk(type = "exec", name = name, sql = sql_txt, tags = tags)

}
```

Note: The package includes helper functions like
[`read_sql_lines()`](https://christian-million.github.io/qryflow/reference/read_sql_lines.md),
[`extract_all_tags()`](https://christian-million.github.io/qryflow/reference/extract_all_tags.md),
[`subset_tags()`](https://christian-million.github.io/qryflow/reference/extract_all_tags.md),
[`is_tag_line()`](https://christian-million.github.io/qryflow/reference/is_tag_line.md),
and others to make parsing easier.

### Handlers

Handlers accepts both a `qryflow_chunk` object and a database connection
object (e.g.,
[`DBI::dbConnect`](https://dbi.r-dbi.org/reference/dbConnect.html)).
They should execute the SQL as appropriate and then return the result:

This is the handler for the “exec” type:

``` r
qryflow_exec_handler <- function(chunk, con, ...) {
  
  # Pass the SQL of the chunk to desired execution strategy
  result <- DBI::dbExecute(con, chunk$sql, ...)

  # Return the result
  result
}
```

After a custom parser and handler have been created, they need to be
registered.

### Validate the Parser and Handler

`qryflow` provides two functions to test whether parser and handler
functions meet the specifications. An error will occur if:

- The object is not a function

- The formal arguments are not included

- The formal arguments are not in the right order

``` r
validate_qryflow_parser(qryflow_exec_parser)
validate_qryflow_handler(qryflow_exec_handler)
```

Note: These obviously do not test that the code within your function is
correct nor does it test what output each function is expected to
produce.

## How the Registry Works

`qryflow` maintains two internal environments:

- `.qryflow_parsers` for chunk parsers

- `.qryflow_handlers` for chunk handlers

When the package is loaded, default types like “`query`” and “`exec`”
are automatically registered. You can register additional types using:

``` r
# Register separately
register_qryflow_parser("custom", my_custom_parser_func, overwrite = TRUE)
register_qryflow_handler("custom", my_custom_handler_func, overwrite = TRUE)

# Or register both at once
register_qryflow_type(
  "custom",
  parser = my_custom_parser_func,
  handler = my_custom_handler_func,
  overwrite = TRUE
)
```

We can access what types are registered:

``` r
ls_qryflow_parsers()
ls_qryflow_handlers()
ls_qryflow_types()
```

Custom types must be re-registered each session. To make them
persistent, add registration calls to your `.Rprofile` (see: [Managing R
Startup](https://docs.posit.co/ide/user/ide/guide/environments/r/managing-r.html)),
or create a small package with an `.onLoad()` hook (see: [R Packages
(2e)](https://r-pkgs.org/code.html#sec-code-onLoad-onAttach)).

## Toy Example \#1: Create `query-send` Chunk Type

This example shows how to implement a new chunk type that’s similar to
`exec` and `query`. We will create a new type, called `query-send` that
works like `query` except calls
[`DBI::dbSendQuery`](https://dbi.r-dbi.org/reference/dbSendQuery.html)
instead of
[`DBI::dbGetQuery`](https://dbi.r-dbi.org/reference/dbGetQuery.html).

First, create the parser and handler:

``` r
query_send_parser <- function(x, ...) {

  # Convert to individual lines
  lines <- read_sql_lines(x)

  all_tags <- extract_all_tags(lines)

  # Check for explicit name
  name <- all_tags$name

  if (is.null(name)) {
    # Accomodate Aliased Approach
    name <- all_tags[["query-send"]]
  }

  other_tags <- subset_tags(all_tags, c("query-send", "name", "type"), negate = TRUE)

  sql_txt <- paste0(lines[!is_tag_line(lines)], collapse = "\n")

  new_qryflow_chunk(type = "query-send", name = name, sql = sql_txt, tags = other_tags)

}

query_send_handler <- function(chunk, con, ...){
  res <- DBI::dbSendQuery(con, chunk$sql, ...)

  results <- DBI::dbFetch(res)
  
  DBI::dbClearResult(res)
  
  results
}
```

Then, register them:

``` r
register_qryflow_type(
  "query-send",
  parser = query_send_parser,
  handler = query_send_handler,
  overwrite = TRUE
)
#> [1] TRUE
```

Check that they registered properly:

``` r
ls_qryflow_types()
#> [1] "exec"       "query"      "query-send"
```

And test it out on some SQL:

``` r
# Creates an in-memory sqlite database and populates it with an mtcars table, named "mtcars" 
con <- example_db_connect(mtcars)

# Create 
sql <- "
-- @query-send: df_mtcars
SELECT *
FROM mtcars;
"

results <- qryflow(sql, con)

head(results)
#>    mpg cyl disp  hp drat    wt  qsec vs am gear carb
#> 1 21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
#> 2 21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
#> 3 22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
#> 4 21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
#> 5 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
#> 6 18.1   6  225 105 2.76 3.460 20.22  1  0    3    1
```

## Exercise: Implement an `include` Chunk Type

Want to try extending `qryflow` on your own?

Implement a custom “`include`” chunk type that loads SQL from a separate
file and injects it as a chunk.

For example, take the following statement:

``` sql
-- @include: mysql.sql

-- @query: my_df
SELECT * FROM table
```

Assuming `mysql.sql` contains:

``` sql
-- @query: mysql
SELECT * INTO table FROM another_table
```

How would you create the parser and handler so that functionally, what
gets returned is:

``` sql
-- @query: mysql
SELECT * INTO table FROM another_table

-- @query: my_df
SELECT * FROM table
```

A word of caution: this may be trickier than you think given how chunks
are currently implemented.
