# zioreporter

Test reporters and CI integration for Zig

Test reporter library for Zig. JUnit XML, HTML, and JSON output formats. CI/CD integration for GitHub Actions, GitLab CI, and Jenkins.

## Features

- JUnit XML output
- HTML report generation
- JSON test results
- CI/CD integration

## Quick Start

```zig
const zioreporter = @import("zioreporter");

pub fn main() !void {
    // See examples/ for runnable code
}
```

## Installation

Add to your `build.zig.zon`:

```zig
.{
    .dependencies = .{
        .zioreporter = .{ .url = "https://github.com/deblasis/zioreporter/archive/refs/heads/main.tar.gz", .hash = "..." },
    },
}
```

Then in your `build.zig`:

```zig
const zioreporter = b.dependency("zioreporter", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("zioreporter", zioreporter.module("zioreporter"));
```

## Examples

Run the included example:

```bash
zig build run-example
```

## API Reference

See [src/zioreporter.zig](src/zioreporter.zig) for full documentation. All public symbols have doc comments.

## Compatibility

- **Zig:** 0.16.0
- **Platforms:** Linux, macOS, Windows
- **Breaking changes:** Follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Minor versions may add features, patch versions fix bugs.

## License

MIT
