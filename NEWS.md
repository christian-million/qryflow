# qryflow (development version)

* Breaking change: `qryflow()`, `qryflow_run()`, `qryflow_execute()` and internal functions now accept `con` argument first, before the `sql`/`workflow` arguments. This makes the API consistent with DBI and other DB packages, improves ergonomics, and enables method dispatch on connection classes. (#5)

* Minor documentation updates (#2)

* Update License Year (#6)

# qryflow 0.1.0

* Initial CRAN submission.
