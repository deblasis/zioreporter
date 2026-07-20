# zioreporter

Test reporting for Zig. Suite tracking, pass/fail counts, duration timing, JUnit XML export.

## The pitch

Collect test results into a suite. Track pass/fail counts, total duration, and export to JUnit XML.

```zig
const std = @import("std");
const zioreporter = @import("zioreporter");

var suite: zioreporter.TestSuite(100) = .{};

// Record test results
try suite.add(.{ .name = "test_auth", .passed = true, .duration_ns = 1500 });
try suite.add(.{ .name = "test_signup", .passed = false, .duration_ns = 2000, .error_message = "duplicate key" });
try suite.add(.{ .name = "test_logout", .passed = true, .duration_ns = 300 });

const passed = suite.passed();          // 2
const failed = suite.failed();          // 1
const duration = suite.totalDuration(); // 3800ns

// Export as JUnit XML for CI integration
var buf: [4096]u8 = undefined;
var stream = std.Io.Writer.fixed(&buf);
try suite.writeJunitXml(&stream);
const xml = stream.buffered();
```

## Install

```bash
zig fetch --save git+https://github.com/deblasis/zioreporter
```

Then in your `build.zig`:

```zig
const dep = b.dependency("zioreporter", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("zioreporter", dep.module("zioreporter"));
```

Requires Zig 0.16.

## API

- `TestSuite(max).add(entry)` - record a test result
- `.passed()` / `.failed()` - count pass/fail
- `.totalDuration()` - sum of durations
- `.writeJunitXml(writer)` - JUnit XML export, times in whole milliseconds
- `TestEntry{ .name, .passed, .error_message, .duration_ns }`

## Compatibility

- **Zig**: 0.16.0
- **Platforms**: Linux, macOS, Windows
- **Breaking changes**: follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Minor versions add features, patch versions fix bugs.

## License

MIT. Copyright (c) 2026 Alessandro De Blasis.
