# Getting Started with qryflow

``` r
library(qryflow)
```

## What is `qryflow`?

The `qryflow` package lets you tag sections of SQL, called chunks, so
that R knows how to execute each part independently. Tagging your SQL
lets you:

- Keep multiple SQL statements in the same file.

- Control how SQL is executed (e.g.,
  [`DBI::dbGetQuery()`](https://dbi.r-dbi.org/reference/dbGetQuery.html),
  [`DBI::dbExecute()`](https://dbi.r-dbi.org/reference/dbExecute.html))

- Attach names to results, so they’re returned as named R objects

- Pass metadata that can be used later in R workflows

In short: You can define and run **multi-step SQL workflows** with one
function call, and get your results back as a structured R object.

This vignette covers:

- How to tag SQL chunks

- The different types of tags supported

- How `qryflow` defines and handles a chunk

## Basic usage

The main function is `qryflow`, which accepts SQL tagged with special
comments and a connection to DBI-compliant database. Note, the SQL can
be a character vector, like in the example below, or a filepath to a
file that contains SQL.

``` r
library(qryflow)

# Connection to In-Memory DB with table populated from mtcars
con <- example_db_connect(mtcars)

sql <- "
-- @exec: drop_cyl_6
DROP TABLE IF EXISTS cyl_6;

-- @exec: prep_cyl_6
CREATE TABLE cyl_6 AS
SELECT *
FROM mtcars
WHERE cyl = 6;

-- @query: df_mtcars
SELECT *
FROM mtcars;

-- @query: df_cyl_6
SELECT *
FROM cyl_6;
"

# Pass tagged SQL to `qryflow`
results <- qryflow(con, sql)

# Access the results from the chunk named `df_cyl_6`
head(results$df_cyl_6)
#>    mpg cyl  disp  hp drat    wt  qsec vs am gear carb
#> 1 21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
#> 2 21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
#> 3 21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
#> 4 18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
#> 5 19.2   6 167.6 123 3.92 3.440 18.30  1  0    4    4
#> 6 17.8   6 167.6 123 3.92 3.440 18.90  1  0    4    4
```

When you run
[`qryflow()`](https://christian-million.github.io/qryflow/reference/qryflow.md),
here’s what happens:

1.  Your SQL script is split into chunks using tag lines like
    `-- @query: df_mtcars`.

2.  Each chunk is assigned a type (e.g., `query` or `exec`)

3.  Chunks are executed in order, and query results are returned as
    named objects

## Simplify = TRUE

By default,
[`qryflow()`](https://christian-million.github.io/qryflow/reference/qryflow.md)
will return a single data.frame (as opposed to a named list of results)
if there is only one chunk and the argument `simplify = TRUE`. For
example:

``` r
library(qryflow)

# Connection to In-Memory DB with table populated from mtcars
con <- example_db_connect(mtcars)

sql <- "
-- @query: df_mtcars
SELECT *
FROM mtcars;
"

# Pass tagged SQL to `qryflow`
results <- qryflow(con, sql)

# Access the results from the chunk named `df_cyl_6`
# results$df_cyl_6
head(results)
#>    mpg cyl disp  hp drat    wt  qsec vs am gear carb
#> 1 21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
#> 2 21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
#> 3 22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
#> 4 21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
#> 5 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
#> 6 18.1   6  225 105 2.76 3.460 20.22  1  0    3    1
```

This design choice is to facilitate easy interactive use and is a common
use-case. Because
[`qryflow()`](https://christian-million.github.io/qryflow/reference/qryflow.md)
might return a named `list` or a single `data.frame` depending on the
input, `qryflow` exports other functions so users can prioritize
reliability in return objects. See the help pages for `?qryflow_run()`
and `?qryflow_results()`. Or check out the Advanced Usage vignette.

## Tagging syntax

To tag a specific chunk of SQL, use the following format:
`-- @key: value`.

For example, to indicate that the following chunk of SQL is a `query`,
meaning we expect it to return a `data.frame` by calling
[`DBI::dbGetQuery`](https://dbi.r-dbi.org/reference/dbGetQuery.html), we
precede the statment with a special comment:

``` sql
-- @query: my_data_frame
SELECT *
FROM TBL
WHERE COLUMN = 'VALUE'
```

Breaking down the tag into it’s component parts:

1.  The tag begins with two dashes (`--`). This indicates a single line
    comment in SQL.

2.  Next, we use the `@` symbol to indicate the start of a tag, followed
    by the tag type. Currently, `qryflow` formally supports four tags:
    `type`, `name`, `query`, and `exec`. We follow the tag type with a
    colon (`:`).

3.  Next comes a value, depending on the type of tag. For the `@type:`
    tag, this will indicate the “type” of SQL chunk. For the `name`,
    `query`, and `exec` tags, the value indicates the custom name of the
    SQL chunk.

## Tags and Aliases

Each SQL chunk must be tagged so `qryflow` knows how to handle it. Tags
use SQL-style comments (`--`) and follow the format:

``` sql
-- @<tag>: <value>
```

### Common Tags

- `@type` Specifies execution type (`-- @type: query`)

- `@name` Assigns a name to the chunk’s result (`-- @name: df_users`)

- `@query` Executes SQL with
  [`DBI::dbGetQuery()`](https://dbi.r-dbi.org/reference/dbGetQuery.html)
  and names the result (`-- @query: df_users`)

- `@exec` Executes SQL with
  [`DBI::dbExecute()`](https://dbi.r-dbi.org/reference/dbExecute.html)
  (`-- @exec: drop_table`)

`@query` and `@exec` are aliases for setting both `@type` and `@name` in
one line.

**Aliased form (preferred):**

``` sql
-- @query: df_mtcars
SELECT *
FROM mtcars;
```

**Explicit form (equivalent):**

``` sql
-- @type: query
-- @name: df_mtcars
SELECT *
FROM mtcars;
```

### Custom Tags

You can include additional tags (e.g., `-- @source: users`) to carry
metadata into your R workflow. Only one execution-related tag is
required per chunk (@query, @exec, or @type).

## Defining a Chunk

In `qryflow`, a Chunk is a logically grouped section of SQL code,
representing a single executable unit within a larger multi-step SQL
workflow.

The SQL script is split into multiple chunks using specially formatted
tag lines (SQL comments beginning with tags like – @query: or – @exec:).
It scans through the SQL lines and splits the script at these tagged
lines, grouping all subsequent SQL lines until the next tag or the end
of the script.

### How Splitting Works

- Tagged lines act as markers that start a new chunk.

- All lines immediately following a tag line belong to that chunk until
  another tag line starts the next chunk.

- If the script has no tags, the entire script is treated as one single
  chunk.

- If there’s only one tag somewhere in the script, the script is split
  into two chunks:

  - Everything before the tag becomes the first chunk (even if
    untagged).

  - The tagged line and everything after it become the second chunk.

### Examples

**Example 1 - Script with no tags**

``` sql
CREATE TABLE cyl_6 AS
SELECT *
FROM mtcars
WHERE cyl = 6;
```

Result - The entire script is one chunk containing all lines.

- Why? Without tags, `qryflow` treats the whole script as a single step.

**Example 2 - Script with one tag at the start**

``` sql
-- @query: get_6cyl
SELECT *
FROM mtcars
WHERE cyl = 6;
```

Result - One chunk starting at the tag, containing the rest of the
script.

Because the tag is at line 1, the chunk starts there and continues to
the end.

**Example 3 - Script with one tag in the middle**

``` sql
SELECT *
FROM mtcars
WHERE cyl = 6;

-- @query: df_mtcars
SELECT *
FROM mtcars;
```

Result - Two chunks:

- Chunk 1: lines before the tag (untagged SQL).

- Chunk 2: from the tag line to the end.

This preserves any pre-tag SQL as a separate chunk.

**Example 4 - Script with multiple tags**

``` sql
-- @exec: drop_cyl_6
DROP TABLE IF EXISTS cyl_6;

-- @exec: prep_cyl_6
CREATE TABLE cyl_6 AS
SELECT *
FROM mtcars
WHERE cyl = 6;

-- @query: df_mtcars
SELECT *
FROM mtcars;

-- @query: df_cyl_6
SELECT *
FROM cyl_6
```

- Result - Four chunks, each starting at its respective tag line.

- Each chunk is parsed and executed independently in sequence.

## Type Identification

Before a chunk is parsed or executed, `qryflow` determines its type
using the following rules:

1.  If a chunk includes an explicit `-- @type:` tag, that value is used
    as the chunk type.

2.  If there is no `@type:` tag, `qryflow` checks for any other tag
    (`@query:`, `@exec:`, etc.) that matches a registered type. The
    first match found is used as the type.

3.  If no recognized tag is found, the type defaults to the value of
    `getOption("qryflow.default.type", "query")`.

Note that formally, “query” is the default type of `qryflow` if the
option is not overridden.
