# Extract metadata from qryflow objects

Extract metadata from qryflow objects

## Usage

``` r
qryflow_meta(x)
```

## Arguments

- x:

  `qryflow` or `qryflow_chunk` object

## Examples

``` r
con <- example_db_connect(mtcars)

filepath <- example_sql_path("mtcars.sql")

parsed <- qryflow_parse(filepath)
qryflow_meta(parsed)
#> $source
#> [1] "-- @exec: drop_cyl_6\nDROP TABLE IF EXISTS cyl_6;\n\n-- @exec: prep_cyl_6\nCREATE TABLE cyl_6 AS\nSELECT *\nFROM mtcars\nWHERE cyl = 6;\n\n-- @query: df_mtcars\nSELECT *\nFROM mtcars;\n\n-- @query: df_cyl_6\nSELECT *\nFROM cyl_6;\n"
#> 
#> $start_time
#> NULL
#> 
#> $end_time
#> NULL
#> 
#> $duration
#> NULL
#> 
#> $status
#> NULL
#> 
#> $error_msg
#> NULL
#> 
qryflow_meta(parsed[[1]])
#> $source
#> [1] "-- @exec: drop_cyl_6\nDROP TABLE IF EXISTS cyl_6;\n"
#> 
#> $start_time
#> NULL
#> 
#> $end_time
#> NULL
#> 
#> $duration
#> NULL
#> 
#> $status
#> NULL
#> 
#> $error_msg
#> NULL
#> 

results <- qryflow_execute(con, parsed)
qryflow_meta(results)
#> $source
#> [1] "-- @exec: drop_cyl_6\nDROP TABLE IF EXISTS cyl_6;\n\n-- @exec: prep_cyl_6\nCREATE TABLE cyl_6 AS\nSELECT *\nFROM mtcars\nWHERE cyl = 6;\n\n-- @query: df_mtcars\nSELECT *\nFROM mtcars;\n\n-- @query: df_cyl_6\nSELECT *\nFROM cyl_6;\n"
#> 
#> $start_time
#> [1] "2026-03-05 14:11:02 UTC"
#> 
#> $end_time
#> [1] "2026-03-05 14:11:02 UTC"
#> 
#> $duration
#> [1] 0.001741886
#> 
#> $status
#> [1] "success"
#> 
#> $error_msg
#> NULL
#> 
qryflow_meta(results[[1]])
#> $source
#> [1] "-- @exec: drop_cyl_6\nDROP TABLE IF EXISTS cyl_6;\n"
#> 
#> $start_time
#> [1] "2026-03-05 14:11:02 UTC"
#> 
#> $end_time
#> [1] "2026-03-05 14:11:02 UTC"
#> 
#> $duration
#> [1] 0.0003008842
#> 
#> $status
#> [1] "success"
#> 
#> $error_msg
#> NULL
#> 

DBI::dbDisconnect(con)
```
