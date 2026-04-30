# zioreporter

## Overview

Test reporter library for Zig. JUnit XML, HTML, and JSON output formats. CI/CD integration for GitHub Actions, GitLab CI, and Jenkins.

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

Single-file library with no external dependencies. All public symbols have doc comments.

## Testing

Tests are inline in `src/zioreporter.zig`. Run with `zig build test`.
