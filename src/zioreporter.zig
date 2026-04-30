//! Test reporters and CI integration for Zig

const std = @import("std");

test "{zioreporter} smoke test" {
    try std.testing.expect(true);
}
