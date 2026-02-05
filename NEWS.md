# qryflow (development version)

* Breaking change: swap argument order of `qryflow()` for arguments `con` and `sql`. Applied same change to all other functions with `con`, like `qryflow_run()` and friends. This makes the API consistent with DBI and other DB packages, improves ergonomics, and enables method dispatch on connection classes.

* Minor documentation updates

* Update License Year

# qryflow 0.1.0

* Initial CRAN submission.
