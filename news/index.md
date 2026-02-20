# Changelog

## qryflow 0.3.0

### Breaking Changes

- The type-specific parser system has been removed
  ([\#13](https://github.com/christian-million/qryflow/issues/13)) .
  `register_qryflow_parser()`, `ls_qryflow_parsers()`
  `validate_qryflow_parser()`, and `qryflow_parser_exists()` are no
  longer available. Custom chunk behaviour should now be implemented
  entirely through handlers. See
  [`register_qryflow_type()`](https://christian-million.github.io/qryflow/reference/register_qryflow_type.md)
  for details.

- `ls_qryflow_handlers()` and `register_qryflow_handler()` were removed.
  Use
  [`ls_qryflow_types()`](https://christian-million.github.io/qryflow/reference/ls_qryflow_types.md)
  and
  [`register_qryflow_type()`](https://christian-million.github.io/qryflow/reference/register_qryflow_type.md)
  instead.

### Internal Changes

- Parsing is now handled by a single unified parser that produces a
  consistent `qryflow_chunk` structure regardless of chunk type. This
  replaces the previous system where each chunk type could define its
  own parsing logic.

- User provided duplicate names now generates an error via refactored
  approach to `fix_chunk_names()` (Now, `resolve_chunk_names()`)

- Updated documentation, README, and vignettes to accomodate unified
  parsing.

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
