# List currently registered chunk types

Helper function to access the names of the currently registered chunk
types.

## Usage

``` r
ls_qryflow_types()
```

## Value

Character vector of registered chunk types

## Details

`ls_qryflow_types` is a shortcut for `ls_qryflow_handlers`. It's
expected that a handler exists for each type.

## Examples

``` r
ls_qryflow_types()
#> [1] "exec"  "query"
```
