# CustomArticle: Documentation

## Usage

- To load this class, use the following command in the preamble:
    ```latex
    \documentclass{CustomArticle}
    ```
  You can also specify the following options when loading the class:
    - `SimpleNumbering`:
      By default, everything (equations, theorems, algorithms, etc.) in this class is numbered by section (1.1, 1.2,
      2.1, etc.). If you want to change this behavior and use the standard numbering (1, 2, 3, ...), turn this option
      on.

- For producing the title (using `\PrintTitleAndAbstract`), it suffices to specify only the `title` key
  in `\PaperGeneralInfo`. Everything else is optional and, if not specified, either will not be displayed at all or
  will be replaced with an appropriate default value (e.g., `\today` for the date).

## Example

See [this LaTeX file](Example/src/Main.tex).