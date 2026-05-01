# zioreporter

Test reporting for Zig. Suite tracking, pass/fail counts, duration timing, error capture.

Collect test results into a suite. Track pass/fail counts, total duration, and error messages per test.

## Quick start

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

## Example output

`zig build run-example` produces:

```
=== zioreporter example ===

Test Suite Results:
  Passed:  3/5
  Failed:  2
  Total:   5100ns

Details:
  PASS test_auth (1500ns)
  PASS test_login (2000ns)
  FAIL test_signup: duplicate key
  PASS test_logout (300ns)
  FAIL test_perms: permission denied
```

See [examples/example.zig](examples/example.zig) for the source.

## API

- `TestSuite(max).add(entry)` — record a test result
- `.passed()` / `.failed()` — count pass/fail
- `.totalDuration()` — sum of all test durations
- `TestEntry{ .name, .passed, .error_message, .duration_ns }` — individual result

## Compatibility

- **Zig**: 0.16.0
- **Platforms**: Linux, macOS, Windows
- **Breaking changes**: follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Minor versions add features, patch versions fix bugs.

## License

MIT. Copyright (c) 2026 Alessandro De Blasis.
