//! Test reporters and CI integration for Zig.

const std = @import("std");

/// A test result entry.
pub const TestEntry = struct {
    name: []const u8,
    passed: bool,
    duration_ns: u64 = 0,
    error_message: []const u8 = "",
};

/// A suite of test results.
pub fn TestSuite(comptime max_tests: usize) type {
    return struct {
        entries: [max_tests]?TestEntry = .{null} ** max_tests,
        count: usize = 0,

        const Self = @This();

        pub fn add(self: *Self, entry: TestEntry) !void {
            if (self.count >= max_tests) return error.TooManyTests;
            self.entries[self.count] = entry;
            self.count += 1;
        }

        pub fn passed(self: *Self) usize {
            var n: usize = 0;
            for (self.entries[0..self.count]) |e| {
                if (e != null and e.?.passed) n += 1;
            }
            return n;
        }

        pub fn failed(self: *Self) usize {
            var n: usize = 0;
            for (self.entries[0..self.count]) |e| {
                if (e != null and !e.?.passed) n += 1;
            }
            return n;
        }

        pub fn totalDuration(self: *Self) u64 {
            var sum: u64 = 0;
            for (self.entries[0..self.count]) |e| {
                if (e) |entry| sum += entry.duration_ns;
            }
            return sum;
        }

        /// Format as JUnit XML.
        pub fn writeJunitXml(self: *Self, writer: anytype) !void {
            try writer.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n", .{});
            try writer.print("<testsuite tests=\"{d}\" failures=\"{d}\" time=\"{d}\">\n", .{
                self.count, self.failed(), self.totalDuration() / std.time.ns_per_ms,
            });
            for (self.entries[0..self.count]) |e| {
                if (e) |entry| {
                    try writer.print("  <testcase name=\"{s}\" time=\"{d}\">", .{
                        entry.name, entry.duration_ns / std.time.ns_per_ms,
                    });
                    if (!entry.passed) {
                        try writer.print("<failure message=\"{s}\"/>", .{entry.error_message});
                    }
                    try writer.print("</testcase>\n", .{});
                }
            }
            try writer.print("</testsuite>\n", .{});
        }
    };
}

test "TestSuite add and count" {
    var suite: TestSuite(10) = .{};
    try suite.add(.{ .name = "test1", .passed = true, .duration_ns = 1000 });
    try suite.add(.{ .name = "test2", .passed = false, .duration_ns = 2000, .error_message = "fail" });
    try std.testing.expectEqual(@as(usize, 2), suite.count);
    try std.testing.expectEqual(@as(usize, 1), suite.passed());
    try std.testing.expectEqual(@as(usize, 1), suite.failed());
}

test "TestSuite totalDuration" {
    var suite: TestSuite(10) = .{};
    try suite.add(.{ .name = "t1", .passed = true, .duration_ns = 5000 });
    try suite.add(.{ .name = "t2", .passed = true, .duration_ns = 3000 });
    try std.testing.expectEqual(@as(u64, 8000), suite.totalDuration());
}
