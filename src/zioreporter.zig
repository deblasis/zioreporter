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


test "TestSuite all passed" {
    var suite: TestSuite(20) = .{};
    for (0..10) |i| {
        try suite.add(.{ .name = "test", .passed = true, .duration_ns = @intCast(i * 1000) });
    }
    try std.testing.expectEqual(@as(usize, 10), suite.passed());
    try std.testing.expectEqual(@as(usize, 0), suite.failed());
}

test "TestSuite all failed" {
    var suite: TestSuite(20) = .{};
    for (0..5) |_| {
        try suite.add(.{ .name = "test", .passed = false, .error_message = "fail" });
    }
    try std.testing.expectEqual(@as(usize, 0), suite.passed());
    try std.testing.expectEqual(@as(usize, 5), suite.failed());
}

test "TestSuite mixed results" {
    var suite: TestSuite(20) = .{};
    try suite.add(.{ .name = "t1", .passed = true, .duration_ns = 100 });
    try suite.add(.{ .name = "t2", .passed = false, .duration_ns = 200, .error_message = "err" });
    try suite.add(.{ .name = "t3", .passed = true, .duration_ns = 300 });
    try std.testing.expectEqual(@as(usize, 2), suite.passed());
    try std.testing.expectEqual(@as(usize, 1), suite.failed());
    try std.testing.expectEqual(@as(u64, 600), suite.totalDuration());
}

test "TestSuite too many tests" {
    var suite: TestSuite(2) = .{};
    try suite.add(.{ .name = "t1", .passed = true });
    try suite.add(.{ .name = "t2", .passed = true });
    try std.testing.expectError(error.TooManyTests, suite.add(.{ .name = "t3", .passed = true }));
}

test "TestEntry defaults" {
    const entry = TestEntry{ .name = "test", .passed = true };
    try std.testing.expectEqualStrings("", entry.error_message);
    try std.testing.expectEqual(@as(u64, 0), entry.duration_ns);
}

test "TestEntry failure with message" {
    const entry = TestEntry{ .name = "test", .passed = false, .error_message = "expected 5, got 3" };
    try std.testing.expect(!entry.passed);
    try std.testing.expectEqualStrings("expected 5, got 3", entry.error_message);
}

test "TestSuite duration calculation" {
    var suite: TestSuite(20) = .{};
    try suite.add(.{ .name = "t1", .passed = true, .duration_ns = 1000 });
    try suite.add(.{ .name = "t2", .passed = true, .duration_ns = 2000 });
    try suite.add(.{ .name = "t3", .passed = true, .duration_ns = 3000 });
    try std.testing.expectEqual(@as(u64, 6000), suite.totalDuration());
}

test "TestSuite empty" {
    var suite: TestSuite(20) = .{};
    try std.testing.expectEqual(@as(usize, 0), suite.passed());
    try std.testing.expectEqual(@as(usize, 0), suite.failed());
    try std.testing.expectEqual(@as(u64, 0), suite.totalDuration());
}

test "TestSuite writeJunitXml basic" {
    var suite: TestSuite(10) = .{};
    try suite.add(.{ .name = "test_auth", .passed = true, .duration_ns = 1000000 });
    try suite.add(.{ .name = "test_fail", .passed = false, .duration_ns = 500000, .error_message = "oops" });
    var buf: [1024]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buf);
    try suite.writeJunitXml(stream.writer());
    const xml = stream.getWritten();
    try std.testing.expect(std.mem.indexOf(u8, xml, "<?xml") != null);
    try std.testing.expect(std.mem.indexOf(u8, xml, "<testsuite") != null);
    try std.testing.expect(std.mem.indexOf(u8, xml, "test_auth") != null);
    try std.testing.expect(std.mem.indexOf(u8, xml, "<failure") != null);
}

test "TestSuite single test pass rate" {
    var suite: TestSuite(10) = .{};
    try suite.add(.{ .name = "only", .passed = true, .duration_ns = 42 });
    try std.testing.expectEqual(@as(usize, 1), suite.count);
    try std.testing.expectEqual(@as(usize, 1), suite.passed());
    try std.testing.expectEqual(@as(usize, 0), suite.failed());
}

test "TestEntry zero duration" {
    const entry = TestEntry{ .name = "instant", .passed = true, .duration_ns = 0 };
    try std.testing.expectEqual(@as(u64, 0), entry.duration_ns);
    try std.testing.expect(entry.passed);
}

test "TestSuite writeJunitXml all passed" {
    var suite: TestSuite(10) = .{};
    try suite.add(.{ .name = "t1", .passed = true, .duration_ns = 500000 });
    try suite.add(.{ .name = "t2", .passed = true, .duration_ns = 300000 });
    var buf: [512]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buf);
    try suite.writeJunitXml(stream.writer());
    const xml = stream.getWritten();
    try std.testing.expect(std.mem.indexOf(u8, xml, "failures=\"0\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, xml, "<failure") == null);
}

test "TestSuite writeJunitXml with failures" {
    var suite: TestSuite(10) = .{};
    try suite.add(.{ .name = "t1", .passed = true, .duration_ns = 100 });
    try suite.add(.{ .name = "t2", .passed = false, .duration_ns = 200, .error_message = "assert failed" });
    var buf: [512]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buf);
    try suite.writeJunitXml(stream.writer());
    const xml = stream.getWritten();
    try std.testing.expect(std.mem.indexOf(u8, xml, "failures=\"1\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, xml, "assert failed") != null);
}

test "TestSuite writeJunitXml with test name" {
    var suite: TestSuite(10) = .{};
    try suite.add(.{ .name = "test_login", .passed = true, .duration_ns = 200000 });
    var buf: [256]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buf);
    try suite.writeJunitXml(stream.writer());
    const xml = stream.getWritten();
    try std.testing.expect(std.mem.indexOf(u8, xml, "test_login") != null);
    try std.testing.expect(std.mem.indexOf(u8, xml, "time=\"200\"") != null);
}
