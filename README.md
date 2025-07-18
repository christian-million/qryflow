
<!-- README.md is generated from README.Rmd. Please edit that file -->

# qryflow

<!-- badges: start -->

[![R-CMD-check](https://github.com/christian-million/qryflow/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/christian-million/qryflow/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/christian-million/qryflow/graph/badge.svg)](https://app.codecov.io/gh/christian-million/qryflow)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/qryflow)](https://cran.r-project.org/package=qryflow)
[![CRAN
status](https://www.r-pkg.org/badges/version/qryflow)](https://cran.r-project.org/package=qryflow)
<!-- badges: end -->

## Overview

Execute multi-step ‘SQL’ statements using specially formatted comments
that define and control execution.

`qryflow` lets you define **multi-step SQL workflows** using
comment-based tags in your SQL code. These tags tell R how to execute
each SQL chunk and what to name the results. This allows you to:

- Keep multiple SQL statements in the same file.

- Control how each SQL “chunk” is executed.

- Return results as named R objects.

- Extend behavior using custom tags, parsers, and handlers.

## Install

You can install the released version of `qryflow` from
[CRAN](https://cran.r-project.org/) with:

``` r
install.packages("qryflow")
```

And the development version from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("christian-million/qryflow")
```

## Example

The code below demonstrates the primary use case for `qryflow`.

Basic Usage:

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
results <- qryflow(sql, con)

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

The path to a file containing SQL can also be passed:

``` r
filepath <- example_sql_path('mtcars.sql')

# Pass tagged SQL to `qryflow`
results <- qryflow(filepath, con)

# Access the results from the chunk named `df_cyl_6`
results$df_cyl_6 |>
  head()
#>    mpg cyl  disp  hp drat    wt  qsec vs am gear carb
#> 1 21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
#> 2 21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
#> 3 21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
#> 4 18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
#> 5 19.2   6 167.6 123 3.92 3.440 18.30  1  0    4    4
#> 6 17.8   6 167.6 123 3.92 3.440 18.90  1  0    4    4
```

## Additional Learning

Consider the following vignettes for a more in depth understanding:

- Getting Started: Outlines available features, how to use `qryflow`,
  and provides an operational understanding of how it works
  (`vignette("getting-started", package = "qryflow")`).

- Advanced Usage: A look under the hood at the objects and classes that
  power `qryflow` so that you can get more out of the package
  (`vignette("advanced-qryflow", package = "qryflow")`).

- Extend `qryflow`: A guide to understanding how to implement custom
  tags, or override the built-in tags, using custom chunk parsers and
  handlers (`vignette("extend-qryflow", package = "qryflow")`).

## Similar Packages

The functionality made available by `qryflow` exists in other packages.
However, the scope and implementation of `qryflow` makes it distinct
enough to justify a unique package.

I recommend reviewing these other packages to see which works best for
your needs. If you feel this list is incomplete, please submit an issue:

- [`sqlhelper`](https://CRAN.R-project.org/package=sqlhelper) provides
  comprehensive tools for executing parameterized SQL scripts, managing
  database connections and configurations, supporting spatial data
  types, and statement-level control within SQL files.
