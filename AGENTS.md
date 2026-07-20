# zioreporter

## Overview

Test reporter library for Zig. Collects test results in a fixed size suite and writes them out as JUnit XML.

## Project Structure

```
src/
  zioreporter.zig    - Main library source
examples/
  example.zig    - Runnable example
build.zig        - Build configuration
```

## Commands

```bash
zig build test          # Run tests
zig build run-example   # Run the example
zig build               - Build the library
```

## Architecture

Single-file library with no external dependencies.

## Testing

Tests are inline in `src/zioreporter.zig`. Run with `zig build test`.
