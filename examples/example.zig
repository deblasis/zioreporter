const std = @import("std");
const zioreporter = @import("zioreporter");

pub fn main() !void {
    std.debug.print("=== zioreporter example ===\n\n", .{});

    var suite: zioreporter.TestSuite(20) = .{};
    try suite.add(.{ .name = "test_auth", .passed = true, .duration_ns = 1500 });
    try suite.add(.{ .name = "test_login", .passed = true, .duration_ns = 2000 });
    try suite.add(.{ .name = "test_signup", .passed = false, .duration_ns = 500, .error_message = "duplicate key" });
    try suite.add(.{ .name = "test_logout", .passed = true, .duration_ns = 300 });
    try suite.add(.{ .name = "test_perms", .passed = false, .duration_ns = 800, .error_message = "permission denied" });

    std.debug.print("Test Suite Results:\n", .{});
    std.debug.print("  Passed:  {d}/{d}\n", .{ suite.passed(), suite.passed() + suite.failed() });
    std.debug.print("  Failed:  {d}\n", .{suite.failed()});
    std.debug.print("  Total:   {d}\n", .{suite.totalDuration()});

    std.debug.print("\nDetails:\n", .{});
    for (suite.entries[0..suite.count]) |maybe_entry| {
        if (maybe_entry) |entry| {
            if (entry.passed) {
                std.debug.print("  PASS {s} ({d}ns)\n", .{ entry.name, entry.duration_ns });
            } else {
                std.debug.print("  FAIL {s}: {s}\n", .{ entry.name, entry.error_message });
            }
        }
    }
}
