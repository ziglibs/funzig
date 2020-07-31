const std = @import("std");
const testing = std.testing;

/// Takes a function of the form:
/// ```zig
/// fn (acc: x, cur: x) y
/// ```
/// `acc` stands for accumulator, or the total
/// `cur` stands for the current value selected in the array
pub fn reduce(comptime func: anytype, comptime init: @typeInfo(@TypeOf(func)).Fn.args[0].arg_type.?) fn ([]@typeInfo(@TypeOf(func)).Fn.args[1].arg_type.?) @typeInfo(@TypeOf(func)).Fn.return_type.? {
    return struct {
        fn call(arr: []@typeInfo(@TypeOf(func)).Fn.args[1].arg_type.?) @typeInfo(@TypeOf(func)).Fn.return_type.? {
            var acc = init;
            for (arr) |cur|
                acc = func(acc, cur);
            return acc;
        }
    }.call;
}

test "Reduce" {
    var my_arr = [_]u8{10, 12, 3};
    std.testing.expectEqual(@as(u8, 25), reduce(struct {
        fn call(acc: u8, cur: u8) u8 {
            return acc + cur;
        }
    }.call, 0)(&my_arr));
}
