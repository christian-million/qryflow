# Advanced Usage with qryflow

``` r
library(qryflow)
```

## Overview

While
[`qryflow()`](https://christian-million.github.io/qryflow/reference/qryflow.md)
provides a simple interface for running tagged SQL workflows, advanced
users may want more control over how scripts are parsed, executed, and
inspected. This vignette demonstrates how to work with the lower-level
building blocks of `qryflow`:

- [`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md):
  End-to-end parser + executor

- [`qryflow_results()`](https://christian-million.github.io/qryflow/reference/qryflow_results.md):
  Extract only the query results

- [`qryflow_parse()`](https://christian-million.github.io/qryflow/reference/qryflow_parse.md):
  Split SQL into structured chunks

- [`qryflow_execute()`](https://christian-million.github.io/qryflow/reference/qryflow_execute.md):
  Execute parsed chunks manually

- Internal object structures: `qryflow_chunk`, `qryflow_workflow`,
  `qryflow_result`

## Using `qryflow_run()` and `qryflow_results()`

The function
[`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md)
performs parsing **and** execution of a SQL workflow, returning a
structured list (of class `qryflow_result`). Unlike
[`qryflow()`](https://christian-million.github.io/qryflow/reference/qryflow.md),
it includes all chunk metadata (not just query results).

``` r
con <- example_db_connect(mtcars)
path <- example_sql_path("mtcars.sql")

obj <- qryflow_run(con, path)

# A qryflow_result object
class(obj)
#> [1] "qryflow_result"
names(obj)
#> [1] "drop_cyl_6" "prep_cyl_6" "df_mtcars"  "df_cyl_6"   "meta"

# Each element is a qryflow_chunk
class(obj$df_mtcars)
#> [1] "qryflow_chunk"
```

To extract only the query results (i.e., what would be returned by
[`qryflow()`](https://christian-million.github.io/qryflow/reference/qryflow.md)),
use:

``` r
results <- qryflow_results(obj)
head(results$df_mtcars)
#>    mpg cyl disp  hp drat    wt  qsec vs am gear carb
#> 1 21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
#> 2 21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
#> 3 22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
#> 4 21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
#> 5 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
#> 6 18.1   6  225 105 2.76 3.460 20.22  1  0    3    1
```

By default, all query chunks are returned as a named list. Set
`simplify = TRUE` to return a single result if only one chunk is
present.

## Parsing and Executing Separately

For advanced introspection, you can manually parse and execute SQL
chunks.

### Step 1: Parse a script

``` r
workflow <- qryflow_parse(path)

class(workflow)
#> [1] "qryflow_workflow"
length(workflow$chunks)
#> [1] 4
workflow$chunks[[1]]
#> <qryflow_chunk> drop_cyl_6
#> 
#> [exec]
#> 
#> DROP TABLE IF EXISTS cyl_6;
#>  ...
```

Each chunk is a structured object of class `qryflow_chunk`, containing:

- `type` (e.g., `"query"`)

- `name` (e.g., `"df_mtcars"`)

- `sql` (the SQL code)

- `tags` (any additional tags)

### Step 2: Execute the workflow

``` r
executed <- qryflow_execute(con, workflow, source = "mtcars.sql")
class(executed)
#> [1] "qryflow_result"
names(executed)
#> [1] "drop_cyl_6" "prep_cyl_6" "df_mtcars"  "df_cyl_6"   "meta"
```

Execution results are stored inside each chunk object, accessible via
`chunk$results`.

## Inspecting `qryflow_result` objects

The result from
[`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md)
or
[`qryflow_execute()`](https://christian-million.github.io/qryflow/reference/qryflow_execute.md)
is a `qryflow_result`, which behaves like a list of chunks plus
metadata.

``` r
head(executed$df_mtcars$results)
#>    mpg cyl disp  hp drat    wt  qsec vs am gear carb
#> 1 21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
#> 2 21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
#> 3 22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
#> 4 21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
#> 5 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
#> 6 18.1   6  225 105 2.76 3.460 20.22  1  0    3    1
executed$df_mtcars$tags
#> list()
executed$meta$timings
#>                 chunk       start_time         end_time
#> 1          drop_cyl_6       1770506196       1770506196
#> 2          prep_cyl_6       1770506196       1770506196
#> 3           df_mtcars       1770506196       1770506196
#> 4            df_cyl_6       1770506196       1770506196
#> 5 overall_qryflow_run 1770506196.45089 1770506196.45251
executed$meta$source
#> [1] "mtcars.sql"
```

You can also use:

``` r
summary(executed)
#> <qryflow_result>
#> Chunks executed: 4 
#> Available objects: drop_cyl_6, prep_cyl_6, df_mtcars, df_cyl_6, meta
```

## Understanding the Underlying Objects

### `qryflow_chunk`

Created by
[`new_qryflow_chunk()`](https://christian-million.github.io/qryflow/reference/new_qryflow_chunk.md).
Structure:

``` r
list(
  type = "query",
  name = "df_mtcars",
  sql = "SELECT * FROM mtcars",
  tags = list(source = "mtcars"),
  results = data.frame(...)
)
```

### `qryflow_workflow`

Created by
[`qryflow_parse()`](https://christian-million.github.io/qryflow/reference/qryflow_parse.md) -
it contains all parsed `qryflow_chunk` objects and optionally the
original SQL script (`source`).

``` r
workflow$chunks[[1]]  # Each is a qryflow_chunk
workflow$source       # Entire original SQL text
```

### `qryflow_result`

Created by
[`qryflow_execute()`](https://christian-million.github.io/qryflow/reference/qryflow_execute.md)
or
[`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md) -
essentially a `qryflow_workflow` plus execution metadata (`meta`) and
filled `results`.

``` r
executed$meta$timings
executed$meta$source
```

## Summary

Use these tools when you need:

- Direct access to parsed chunks (`qryflow_parse`)

- Programmatic control over execution (`qryflow_execute`)

- Access to timing and SQL source metadata (`qryflow_result`)

- Selective re-execution or filtering of chunks

See the “Extending qryflow”
([`vignette("extend-qryflow", package = "qryflow")`](https://christian-million.github.io/qryflow/articles/extend-qryflow.md))
vignette for registering custom chunk types or defining new behaviors.
