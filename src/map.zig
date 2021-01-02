const std = @import("std");

pub fn map(comptime func: anytype) fn ([]@typeInfo(@TypeOf(func)).Fn.args[0].arg_type.?, []@typeInfo(@TypeOf(func)).Fn.return_type.?) anyerror!void {
    return struct {
        fn call(arr: []@typeInfo(@TypeOf(func)).Fn.args[0].arg_type.?, out: []@typeInfo(@TypeOf(func)).Fn.return_type.?) anyerror!void {
            for (arr) |cur, idx|
                out[idx] = func(cur);
        }
    }.call;
}

pub fn mapAlloc(comptime allocator: *std.mem.Allocator, comptime func: anytype) fn ([]@typeInfo(@TypeOf(func)).Fn.args[0].arg_type.?) anyerror![]@typeInfo(@TypeOf(func)).Fn.return_type.? {
    return struct {
        fn call(arr: []@typeInfo(@TypeOf(func)).Fn.args[0].arg_type.?) anyerror![]@typeInfo(@TypeOf(func)).Fn.return_type.? {
            var out = try allocator.alloc(@typeInfo(@TypeOf(func)).Fn.return_type.?, arr.len);
            for (arr) |cur, idx|
                out[idx] = func(cur);
            return out;
        }
    }.call;
}

test "Map" {
    const testMap = map(struct {
        fn call(in: u8) u8 {
            return in + 1;
        }
    }.call);

    var arr = [_]u8{'a', 'b', 'c'};
    var out = [_]u8{0} ** 3;
    try testMap(&arr, &out);
    std.testing.expectEqualSlices(u8, &[_]u8{'b', 'c', 'd'}, &out);
}

test "Map w/ Allocations" {
    const testMapAlloc = mapAlloc(std.testing.allocator, struct {
        fn call(in: u8) u8 {
            return in + 1;
        }
    }.call);

    var arr = [_]u8{'a', 'b', 'c'};
    var out = try testMapAlloc(&arr);
    defer std.testing.allocator.free(out);
    std.testing.expectEqualSlices(u8, &[_]u8{'b', 'c', 'd'}, out);
}
