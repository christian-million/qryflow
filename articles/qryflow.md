# Getting Started with qryflow

``` r
library(qryflow)
#> Warning: S3 methods 'as.data.frame.qryflow_chunk', 'as.list.qryflow_chunk' were
#> declared in NAMESPACE but not found
```

## What is `qryflow`?

`qryflow` lets you write multi-step SQL workflows in plain `.sql` files
and run them from R with a single function call. Specially formatted
tags tell R how to execute each SQL chunk and what to name the results.
This allows you to:

- Keep multiple SQL statements in the same file.

- Control how each SQL “chunk” is executed.

- Return results as named R objects.

- Pass metadata that can be used later in R workflows

In short: You can define and run **multi-step SQL workflows** with one
function call, and get your results back as a structured R object.

## Basic usage

The main function is `qryflow`, which accepts SQL tagged with special
comments and a connection to DBI-compliant database. Note, the SQL can
be a character vector, like in the example below, or a filepath to a
file that contains SQL.

``` r
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

-- @query: df_cyl_6
SELECT *
FROM cyl_6;
"

# Pass tagged SQL to `qryflow`
results <- qryflow(con, sql, verbose = TRUE)
#> Running 3 chunks
#> [1/3] drop_cyl_6 [exec]
#>       ✓ success  0s
#> [2/3] prep_cyl_6 [exec]
#>       ✓ success  0s
#> [3/3] df_cyl_6 [query]
#>       ✓ success  0s
#> Done in 0s — 3 success, 0 error, 0 skipped

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

By default, the package supports `@exec` tags, which are executed with
[`DBI::dbExecute()`](https://dbi.r-dbi.org/reference/dbExecute.html) and
`@query` tags, which are executed with
[`DBI::dbGetQuery()`](https://dbi.r-dbi.org/reference/dbGetQuery.html).

When you run
[`qryflow()`](https://christian-million.github.io/qryflow/reference/qryflow.md):

1.  The SQL script is split into chunks using tag lines like
    `-- @query: df_mtcars`.

2.  Each chunk is assigned a type (e.g., `query` or `exec`)

3.  Chunks are executed in order, using the associated execution type

4.  The results are returned as named objects

## Defining a Chunk

In `qryflow`, a chunk is a grouped section of SQL code, representing a
single executable unit within a larger multi-step SQL workflow, and
preceded by one or more tag lines (e.g., the pattern
`-- @<tag>: <value>`).

- Tagged lines act as markers that start a new chunk.

- All lines (comments and SQL) immediately following a contiguous group
  of tagged lines belong to that chunk until another tag line starts the
  next chunk.

- If the script has no tags, the entire script is treated as one single
  chunk.

## Tags and Aliases

Each SQL chunk must be tagged with a `type` so `qryflow` knows how to
execute it. If a chunk is not provided with a tag, the `qryflow` engine
will use the value of the `default_type` argument, which can be provided
directly or set with `getOption("qryflow.default_type", "query")`. It
defaults to “query”, as getting data out is the most common use case.

Tags use SQL-style comments (`--`) and follow the format:

``` sql
-- @<tag>: <value>
```

### Important Tags

Each chunk should have both a `name` (the name of the object when
returned to R) and a `type` (execution mode for the chunk). Users can
set these explicitly with the following tags:

- `@type` apecifies execution type (`-- @type: query`)

- `@name` assigns a name to the chunk’s result (`-- @name: df_users`)

For registered types, users can use shorthand to supply both name and
type in one line. For example, `@query` and `@exec` are aliases for
setting both `@type` and `@name` in one line.

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

### Type Identification

During parsing, `qryflow` determines its type using the following rules:

1.  If a chunk includes an explicit `-- @type:` tag, that value is used
    as the chunk type.

2.  If there is no `@type:` tag, `qryflow` checks for any other tag that
    matches a registered type (`@query:`, `@exec:`, etc.) . The first
    match found is used as the type.

3.  If no recognized tag is found, the type defaults to the value of
    `getOption("qryflow.default_type", "query")`.

### Passing Additional Tags

You can include additional tags to carry metadata into your R workflow,
that follow the tagging structure:

``` sql
-- @exec: df_mtcars
-- @src: dbo.mtcars
-- @topic: cars
SELECT *
FROM mtcars;
```

## Important Arguments

### on_error

The `on_error` argument controls what happens when a single chunk fails:

- `"stop"` (default): halts execution immediately and raises an error.

- `"warn"`: records the error and signals a warning, but continues
  running remaining chunks.

- `"collect"`: silently collects all errors across all chunks and raises
  a single combined error at the end.

``` r
# on_error = "stop" (default): halts on first failure
bad_sql <- "
-- @exec: prep_cyl_6
CREATE TABLE cyl_6 AS SELECT * FROM mtcars WHERE cyl = 6;

-- @query: df_missing
SELECT * FROM nonexistent_table;

-- @query: df_mtcars
SELECT * FROM mtcars;
"

qryflow(con, bad_sql, on_error = "stop")
#> Error:
#> ! Chunk 'prep_cyl_6' failed with message: 'table cyl_6 already exists'
```

``` r
# Warn collects errors and signals a warning
qryflow(con, bad_sql, on_error = "warn")
#> Warning: table cyl_6 already exists
#> Warning: no such table: nonexistent_table
```

``` r
# on_error = "collect": runs everything, then reports all failures together
qryflow(con, bad_sql, verbose = TRUE, on_error = "collect")
#> Running 3 chunks
#> [1/3] prep_cyl_6 [exec]
#>       ✗ error    0s
#> [2/3] df_missing [query]
#>       ✗ error    0s
#> [3/3] df_mtcars [query]
#>       ✓ success  0s
#> Done in 0s — 0 success, 0 error, 0 skipped
#> Error:
#> ! 2 chunks failed:
#>   - prep_cyl_6: table cyl_6 already exists
#>   - df_missing: no such table: nonexistent_table
```

### verbose

By default, `qryflow` is quiet. However, for long running queries with
multiple chunks, you may want feedback on which chunks are currently
running. You can use `verbose = TRUE` to get updates during execution.

### simplify

When `simplify = TRUE`, in the case where there is only one chunk,
[`qryflow()`](https://christian-million.github.io/qryflow/reference/qryflow.md)
will return a single object (as opposed to a named list of results). For
example:

``` r
sql1 <- "
-- @query: df_mtcars
SELECT *
FROM mtcars;
"

sql2 <- "
-- @query: df_mtcars
SELECT *
FROM mtcars;

-- @query: df_mtcars_cyl6
SELECT *
FROM mtcars
WHERE cyl = 6;
"

# Pass tagged SQL to `qryflow`
res1 <- qryflow(con, sql1, simplify = TRUE)
res2 <- qryflow(con, sql2, simplify = TRUE)
res3 <- qryflow(con, sql1, simplify = FALSE)

class(res1) # simplifies the result to the single data.frame() because only one chunk
#> [1] "data.frame"
class(res2) # returns named list
#> [1] "list"
class(res3) # returns named list, because simplify = FALSE
#> [1] "list"
```

This design choice is to facilitate easy interactive use and is a common
use-case. Because
[`qryflow()`](https://christian-million.github.io/qryflow/reference/qryflow.md)
might return a named `list` or a single `data.frame` depending on the
input, the `qryflow` package exports other functions so users can
prioritize reliability in return objects. The next section explores
functions like
[`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md)
and
[`qryflow_results()`](https://christian-million.github.io/qryflow/reference/qryflow_results.md)
further.

## The Core API

While
[`qryflow()`](https://christian-million.github.io/qryflow/reference/qryflow.md)
covers most use cases, users who want more control and consistency may
prefer to use the functions that
[`qryflow()`](https://christian-million.github.io/qryflow/reference/qryflow.md)
leverages:

- [`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md)

- `qrflow_results()`

- [`qryflow_parse()`](https://christian-million.github.io/qryflow/reference/qryflow_parse.md)

- `qryflow_execute`

### `qryflow_run()` and `qryflow_results()`

[`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md)
performs parsing *and* execution, returning a full `qryflow` object -
including all chunk metadata, not just the query results.

``` r
obj <- qryflow_run(con, sql)

# A qryflow object
class(obj)
#> [1] "qryflow"

# Chunk names are top-level list names
names(obj)
#> [1] "drop_cyl_6" "prep_cyl_6" "df_cyl_6"

obj # Print Method
#> ── qryflow ───────────────────────────────────────────────────────────────────── 
#>   chunks: 3 | status: success | duration: 0s 
#> 
#>   drop_cyl_6  [exec ]  ✓ success  0s
#>   prep_cyl_6  [exec ]  ✓ success  0s
#>   df_cyl_6    [query]  ✓ success  0s
```

Each element is a `qryflow_chunk`:

``` r
class(obj$df_cyl_6)
#> [1] "qryflow_chunk"

# Print the chunk
obj$df_cyl_6
#> ── qryflow_chunk: df_cyl_6 ───────────────────────────────────────────────────── 
#>   type: query | ✓ success | duration: 0s
#> 
#>   SELECT *
#>   FROM cyl_6;
```

To extract only the query results (equivalent to what
[`qryflow()`](https://christian-million.github.io/qryflow/reference/qryflow.md)
returns), use
[`qryflow_results()`](https://christian-million.github.io/qryflow/reference/qryflow_results.md):

``` r
results <- qryflow_results(obj)
class(results$df_cyl_6)
#> [1] "data.frame"
head(results$df_cyl_6)
#>    mpg cyl  disp  hp drat    wt  qsec vs am gear carb
#> 1 21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
#> 2 21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
#> 3 21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
#> 4 18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
#> 5 19.2   6 167.6 123 3.92 3.440 18.30  1  0    4    4
#> 6 17.8   6 167.6 123 3.92 3.440 18.90  1  0    4    4
```

### `qryflow_parse()` and `qryflow_execute()`

For even more control, you can parse and execute separately:

``` r
# Step 1: Parse the SQL into structured chunks
filepath <- example_sql_path()
workflow <- qryflow_parse(filepath)

class(workflow)
#> [1] "qryflow"
length(workflow)
#> [1] 4
names(workflow)
#> [1] "drop_cyl_6" "prep_cyl_6" "df_mtcars"  "df_cyl_6"

# Inspect a chunk before execution
workflow$df_mtcars
#> ── qryflow_chunk: df_mtcars ──────────────────────────────────────────────────── 
#>   type: query |   pending  
#> 
#>   SELECT *
#>   FROM mtcars;
```

Each `qryflow_chunk` contains:

- `$type`: the execution type (e.g., `"query"`)
- `$name`: the chunk name
- `$sql`: the SQL body
- `$tags`: any additional tags
- `$results`: `NULL` before execution; populated after

``` r
# Step 2: Execute the parsed workflow
executed <- qryflow_execute(con, workflow)

class(executed)
#> [1] "qryflow"
names(executed)
#> [1] "drop_cyl_6" "prep_cyl_6" "df_mtcars"  "df_cyl_6"
executed
#> ── qryflow ───────────────────────────────────────────────────────────────────── 
#>   chunks: 4 | status: success | duration: 0s 
#> 
#>   drop_cyl_6  [exec ]  ✓ success  0s
#>   prep_cyl_6  [exec ]  ✓ success  0s
#>   df_mtcars   [query]  ✓ success  0s
#>   df_cyl_6    [query]  ✓ success  0s
```

## Metadata

Both the worfklow object (`qryflow`) and the chunk objects
(`qryflow_chunk`) store metadata about the execution. You can access
this information with the
[`qryflow_meta()`](https://christian-million.github.io/qryflow/reference/qryflow_meta.md)
function:

``` r
qryflow_meta(executed) # The whole workflow
#> $source
#> [1] "-- @exec: drop_cyl_6\nDROP TABLE IF EXISTS cyl_6;\n\n-- @exec: prep_cyl_6\nCREATE TABLE cyl_6 AS\nSELECT *\nFROM mtcars\nWHERE cyl = 6;\n\n-- @query: df_mtcars\nSELECT *\nFROM mtcars;\n\n-- @query: df_cyl_6\nSELECT *\nFROM cyl_6;\n"
#> 
#> $start_time
#> [1] "2026-03-05 13:48:03 UTC"
#> 
#> $end_time
#> [1] "2026-03-05 13:48:03 UTC"
#> 
#> $duration
#> [1] 0.001842976
#> 
#> $status
#> [1] "success"
#> 
#> $error_msg
#> NULL
```

``` r
qryflow_meta(executed[[1]]) # The whole chunk
#> $source
#> [1] "-- @exec: drop_cyl_6\nDROP TABLE IF EXISTS cyl_6;\n"
#> 
#> $start_time
#> [1] "2026-03-05 13:48:03 UTC"
#> 
#> $end_time
#> [1] "2026-03-05 13:48:03 UTC"
#> 
#> $duration
#> [1] 0.0004549026
#> 
#> $status
#> [1] "success"
#> 
#> $error_msg
#> NULL
```

## Summary

| Function                                                                                        | What it does                                                       |
|-------------------------------------------------------------------------------------------------|--------------------------------------------------------------------|
| [`qryflow()`](https://christian-million.github.io/qryflow/reference/qryflow.md)                 | Parse + execute + return query results.                            |
| [`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md)         | Parse + execute, returning a full `qryflow` object with metadata.  |
| [`qryflow_results()`](https://christian-million.github.io/qryflow/reference/qryflow_results.md) | Extract query results from a `qryflow` object.                     |
| [`qryflow_parse()`](https://christian-million.github.io/qryflow/reference/qryflow_parse.md)     | Parse SQL into structured `qryflow` object - No execution.         |
| [`qryflow_execute()`](https://christian-million.github.io/qryflow/reference/qryflow_execute.md) | Execute a parsed `qryflow` object against a connection.            |
| [`qryflow_meta()`](https://christian-million.github.io/qryflow/reference/qryflow_meta.md)       | Access metadata (status, duration, timing) on a workflow or chunk. |

For a guide on registering custom chunk types and extending `qryflow`’s
behaviour, see
[`vignette("extend-qryflow", package = "qryflow")`](https://christian-million.github.io/qryflow/articles/extend-qryflow.md).

## Examples

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
