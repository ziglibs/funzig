const std = @import("std");
pub const pipe = @import("src/pipe.zig").pipe;
pub const reduce = @import("src/reduce.zig").reduce;

comptime {
    _ = std.meta.refAllDecls(@This());
}
