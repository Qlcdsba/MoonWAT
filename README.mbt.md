# moonparsec

A high-performance, type-safe, and zero-copy **Parser Combinator Library** for MoonBit.

`moonparsec` allows you to build complex parsers (for JSON, CSV, configuration formats, or custom domain-specific languages) by combining small, simple, and easily testable parser functions.

## Features

- **Type-Safe & Declarative**: Define parsers using type-safe functional combinators like `map`, `and_then`, `or`, `many0`, and more.
- **Zero-Copy Performance**: Uses string slices and offsets under the hood to minimize allocations during parsing.
- **Position & Span Tracking**: Automatically tracks the exact line, column, and span of matches, making it easy to report precise source code locations.
- **Rich Error Diagnosis**: Generates formatted, user-friendly compiler-like diagnostic messages with visual squiggly lines pointing to the error context.
- **RFC-Compliant Examples**: Includes a complete RFC 4180 compliant CSV parser and a fully-featured JSON parser built entirely using the library combinators.

## Quick Start

Here is a quick example of defining a simple parser for coordinates like `(12, 34)`:

```moonbit
// Coming soon in implementation!
```