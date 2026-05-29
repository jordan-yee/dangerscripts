---
paths:
  - "**/*.md"
  - "**/*.markdown"
---

# Markdown Rules

## Line Wrapping

Wrap continuous paragraph text at 80 characters for readability as raw text in
an editor. This applies to prose paragraphs — do not wrap:
- Code blocks
- Tables
- Lists (each item may wrap naturally, but do not insert hard breaks mid-item)
- Headings
- URLs (keep on one line even if over 80 characters)

## Tables

Align table columns so they read cleanly as plain text: pad each cell to its
column's width, and always give the header and divider (`|---|`) rows those same
widths. That baseline alignment applies to every table.

When a column's width is driven by a small minority of cells far longer than the
rest, don't pad every row out to that outlier. Size the column to the bulk (its
longest non-outlier cell) and let the outlier cells overflow past the column.
Count a cell as an outlier when it is roughly 1.5x or more the next-longest cell
in its column and such cells are a minority (about a third of the rows or fewer).
When most rows are long, with no clear bulk-versus-outlier split, align fully to
the true maximum width instead.

Whether overflow is acceptable depends on the column's position. In the last
column an overflowing cell just runs long and every separator still lines up; in
an earlier column it pushes that row's later cells out of alignment. So:
- Last column: trim to the bulk and let outliers overflow whenever there is a clear minority outlier.
- Other columns: default to padding to the column's true maximum so every row stays aligned; only trim to the bulk (letting the outlier overflow) when the wasted width clearly outweighs the cost.

When a cell does overflow, preserve all the alignment the overflow doesn't
actually break, rather than collapsing the row. An overflowing cell only
disturbs the cells to its right on the same row, so keep every column before it
aligned and keep all other rows aligned — only the cells after the overflow, on
that one row, go ragged.
