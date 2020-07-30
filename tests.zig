const std = @import("std");
const testing = std.testing;
const pipe = @import("exports.zig").pipe;

fn addOne(num: u8) u8 {
    return num + 1;
}

fn addOneError(num: u8) !u8 {
    if (num == 69) return error.Nice;
    return num * 2;
}

fn addX(comptime x: usize) fn (usize) usize {
    return struct {
        fn add(in: usize) usize {
            return in + x;
        }
    }.add;
}

fn subX(comptime x: usize) fn (usize) usize {
    return struct {
        fn add(in: usize) usize {
            return in - x;
        }
    }.add;
}

fn mulX(comptime x: usize) fn (usize) usize {
    return struct {
        fn add(in: usize) usize {
            return in * x;
        }
    }.add;
}

test "Basic pipe" {

    const add_pipe = pipe(.{
        addOne,
        addOneError
    });

    std.testing.expectEqual(@as(u8, 22), try add_pipe(10));
    std.testing.expectError(error.Nice, add_pipe(68));

    const addX_pipe = pipe(.{
        comptime addX(5),
        comptime mulX(10),
        comptime subX(10)
    });

    std.testing.expectEqual(@as(usize, 190), addX_pipe(15));

}
