# List currently registered chunk types

Helper function to access the names of the currently registered chunk
types. Functions available for accessing just the parsers or just the
handlers.

## Usage

``` r
ls_qryflow_handlers()

ls_qryflow_parsers()

ls_qryflow_types()
```

## Value

Character vector of registered chunk types

## Details

`ls_qryflow_types` is implemented to return the union of the results of
`ls_qryflow_parsers` and `ls_qryflow_handlers`. It's expected that a
both a parser and a handler exist for each type. If this assumption is
violated, the `ls_qryflow_types` may suggest otherwise.

## Examples

``` r
ls_qryflow_types()
#> [1] "exec"  "query"
```
