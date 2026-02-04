# Create an instance of the `qryflow_chunk` class

Create an instance of the `qryflow_chunk` class

## Usage

``` r
new_qryflow_chunk(
  type = character(),
  name = character(),
  sql = character(),
  tags = NULL,
  results = NULL
)
```

## Arguments

- type:

  Character indicating the type of chunk (e.g., "query", "exec")

- name:

  Name of the chunk

- sql:

  SQL statement associated with chunk

- tags:

  Optional, additional tags included in chunk

- results:

  Optional, filled in after chunk execution

## Value

An list-like object of class `qryflow_chunk`

## Details

Exported for users intending to extend qryflow. Subsequent processes
rely on the structure of a qryflow_chunk.

## Examples

``` r
chunk <- new_qryflow_chunk("query", "df_name", "SELECT * FROM mtcars;")
```
