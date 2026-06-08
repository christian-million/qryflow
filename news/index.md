# Changelog

## qryflow (development version)

### Breaking Changes

- The `source` argument has been removed from
  [`qryflow_execute()`](https://christian-million.github.io/qryflow/reference/qryflow_execute.md).
  Source information is now stored automatically in chunk metadata
  during parsing.

- `qryflow_default_type()` has been removed as a standalone exported
  function. Default type is now controlled directly via the
  `default_type` argument in
  [`qryflow()`](https://christian-million.github.io/qryflow/reference/qryflow.md),
  [`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md),
  and
  [`qryflow_parse()`](https://christian-million.github.io/qryflow/reference/qryflow_parse.md),
  or through the global option
  `options(qryflow.default_type = "query")`. Note: the option key has
  changed from `qryflow.default.type` to `qryflow.default_type`.

### New Features

- `on_error` argument added to
  [`qryflow()`](https://christian-million.github.io/qryflow/reference/qryflow.md),
  [`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md),
  and
  [`qryflow_execute()`](https://christian-million.github.io/qryflow/reference/qryflow_execute.md).
  Controls behavior when a chunk fails during execution. Accepts
  `"stop"` (default, halts immediately), `"warn"` (signals a warning and
  continues), or `"collect"` (runs all chunks and reports all errors
  together at the end).
  ([\#11](https://github.com/christian-million/qryflow/issues/11) and
  [\#12](https://github.com/christian-million/qryflow/issues/12)

- `verbose` argument added to
  [`qryflow()`](https://christian-million.github.io/qryflow/reference/qryflow.md),
  [`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md),
  and
  [`qryflow_execute()`](https://christian-million.github.io/qryflow/reference/qryflow_execute.md).
  When `TRUE`, emits a progress message before each chunk and a summary
  upon completion showing total runtime, successes, errors, and skipped
  chunks. Defaults to `FALSE`. Can be enabled globally with
  `options(qryflow.verbose = TRUE)`.
  (\[[\#8](https://github.com/christian-million/qryflow/issues/8)\])

- `default_type` argument added to
  [`qryflow()`](https://christian-million.github.io/qryflow/reference/qryflow.md),
  [`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md),
  and
  [`qryflow_parse()`](https://christian-million.github.io/qryflow/reference/qryflow_parse.md).
  Determines the chunk type assigned to untagged chunks. Defaults to
  `"query"`. Can be set globally with
  `options(qryflow.default_type = "query")`.

- [`qryflow_meta()`](https://christian-million.github.io/qryflow/reference/qryflow_meta.md)
  is now an exported function for accessing execution metadata (status,
  duration, start/end times, error messages) from both `qryflow`
  workflow objects and individual `qryflow_chunk` objects.

- `validate_con_arg()` is now called internally by
  [`qryflow_execute()`](https://christian-million.github.io/qryflow/reference/qryflow_execute.md)
  to provide clear, actionable error messages when the connection
  argument is missing, invalid, or disconnected.

- Workflow-level execution status is now tracked and stored in metadata.
  A completed workflow is assigned a status of `"success"` if all chunks
  succeeded, or `"partial"` if any chunk encountered an error.

### Internal Changes

- Combined `qryflow_workflow` and `qryflow_results` into single object.
  (\[[\#14](https://github.com/christian-million/qryflow/issues/14)\])

- Added `cli.R` with verbose helpers (`report_workflow_start()`,
  `report_chunk_start()`, `report_chunk_end()`,
  `report_workflow_end()`).

- Added `on-error.R` consolidating error dispatch logic
  (`validate_on_error()`, `dispatch_on_error()`,
  `dispatch_collected_errors()`) supporting the new `on_error` argument.

- Metadata handling has been refactored into `meta.R`, centralizing time
  tracking and duration formatting used across workflow and chunk
  objects.

- Updated documentation, vignettes, and README to reflect new arguments
  and removed functions.

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
