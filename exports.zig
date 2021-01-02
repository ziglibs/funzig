const std = @import("std");
pub usingnamespace @import("src/map.zig");
pub usingnamespace @import("src/find.zig");
pub const pipe = @import("src/pipe.zig").pipe;
pub const reduce = @import("src/reduce.zig").reduce;

comptime {
    _ = std.testing.refAllDecls(@This());
}

test "Combo!" {
    const pipeTest = pipe(.{
        comptime reduce((struct {
            fn call(acc: u8, cur: u8) u8 {
                return acc + cur;
            }
        }).call, 0),
        (struct {
            fn call(val: u8) u8 {
                return val + 10;
            }
        }).call
    });


    var arr = [_]u8{10, 20, 30};
    std.testing.expectEqual(@as(u8, 70), pipeTest(&arr));
}
