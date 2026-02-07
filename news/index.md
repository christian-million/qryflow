# Changelog

## qryflow (development version)

## qryflow 0.2.0

CRAN release: 2026-02-05

- Breaking change:
  [`qryflow()`](https://christian-million.github.io/qryflow/reference/qryflow.md),
  [`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md),
  [`qryflow_execute()`](https://christian-million.github.io/qryflow/reference/qryflow_execute.md)
  and internal functions now accept `con` argument first, before the
  `sql`/`workflow` arguments. This makes the API consistent with DBI and
  other DB packages, improves ergonomics, and enables method dispatch on
  connection classes.
  ([\#5](https://github.com/christian-million/qryflow/issues/5))

- Minor documentation updates
  ([\#2](https://github.com/christian-million/qryflow/issues/2))

- Update License Year
  ([\#6](https://github.com/christian-million/qryflow/issues/6))

## qryflow 0.1.0

CRAN release: 2025-07-18

- Initial CRAN submission.
