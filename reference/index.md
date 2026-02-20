# Package index

## Running and Managing ‘SQL’ Workflows

Functions for executing multi-step SQL workflows with tagged SQL
scripts. These tools let you parse SQL into chunks, control execution,
and retrieve structured results.

- [`qryflow()`](https://christian-million.github.io/qryflow/reference/qryflow.md)
  : Run a multi-step SQL workflow and return query results

- [`qryflow_run()`](https://christian-million.github.io/qryflow/reference/qryflow_run.md)
  : Parse and execute a tagged SQL workflow

- [`qryflow_results()`](https://christian-million.github.io/qryflow/reference/qryflow_results.md)
  :

  Extract results from a `qryflow_workflow` object

- [`qryflow_parse()`](https://christian-million.github.io/qryflow/reference/qryflow_parse.md)
  : Parse a SQL workflow into tagged chunks

- [`qryflow_execute()`](https://christian-million.github.io/qryflow/reference/qryflow_execute.md)
  : Execute a parsed qryflow SQL workflow

## Registration

Functions that allow users to register custom types and inspect the
registry. These are useful for extending qryflow.

- [`register_qryflow_type()`](https://christian-million.github.io/qryflow/reference/register_qryflow_type.md)
  : Register custom chunk types
- [`qryflow_handler_exists()`](https://christian-million.github.io/qryflow/reference/qryflow_handler_exists.md)
  : Check existence of a given handler in the registry
- [`ls_qryflow_types()`](https://christian-million.github.io/qryflow/reference/ls_qryflow_types.md)
  : List currently registered chunk types
- [`validate_qryflow_handler()`](https://christian-million.github.io/qryflow/reference/validate_qryflow_handler.md)
  : Ensure correct handler structure

## Helpers for Extending qryflow

These functions are exported to help users extend qryflow with custom
parsers and handlers.

- [`read_sql_lines()`](https://christian-million.github.io/qryflow/reference/read_sql_lines.md)
  : Standardizes lines read from string, character vector, or file

- [`collapse_sql_lines()`](https://christian-million.github.io/qryflow/reference/collapse_sql_lines.md)
  : Collapse SQL lines into single character

- [`is_tag_line()`](https://christian-million.github.io/qryflow/reference/is_tag_line.md)
  : Detect the presence of a properly structured tagline

- [`extract_all_tags()`](https://christian-million.github.io/qryflow/reference/extract_all_tags.md)
  [`extract_tag()`](https://christian-million.github.io/qryflow/reference/extract_all_tags.md)
  [`extract_name()`](https://christian-million.github.io/qryflow/reference/extract_all_tags.md)
  [`extract_type()`](https://christian-million.github.io/qryflow/reference/extract_all_tags.md)
  [`subset_tags()`](https://christian-million.github.io/qryflow/reference/extract_all_tags.md)
  : Extract tagged metadata from a SQL chunk

- [`new_qryflow_chunk()`](https://christian-million.github.io/qryflow/reference/new_qryflow_chunk.md)
  :

  Create an instance of the `qryflow_chunk` class

- [`qryflow_default_type()`](https://christian-million.github.io/qryflow/reference/qryflow_default_type.md)
  : Access the default qryflow chunk type

## Example Utilities

These functions help to quickly prepare the environment to demonstrate
qryflow functionality. Used in the examples, vignettes, and in the
testing suite.

- [`example_db_connect()`](https://christian-million.github.io/qryflow/reference/example_db_connect.md)
  : Create an example in-memory database
- [`example_sql_path()`](https://christian-million.github.io/qryflow/reference/example_sql_path.md)
  : Get path to qryflow example SQL scripts
