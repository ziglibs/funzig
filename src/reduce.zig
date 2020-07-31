const std = @import("std");
const testing = std.testing;

/// Takes a function of the form:
/// ```zig
/// fn (acc: x, cur: x) y
/// ```
/// `acc` stands for accumulator, or the total
/// `cur` stands for the current value selected in the array
pub fn reduce(comptime func: anytype, arr: []@typeInfo(@TypeOf(func)).Fn.args[1].arg_type.?, init: @typeInfo(@TypeOf(func)).Fn.args[0].arg_type.?) @typeInfo(@TypeOf(func)).Fn.return_type.? {
    var acc = init;
    for (arr) |cur|
        acc = func(acc, cur);
    return acc;
}

fn addAll(acc: u8, cur: u8) u8 {
    return acc + cur;
}

test "Reduce" {
    var my_arr = [_]u8{10, 12, 3};
    std.testing.expectEqual(@as(u8, 25), reduce(addAll, &my_arr, 0));
}
