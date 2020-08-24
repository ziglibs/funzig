const std = @import("std");

pub fn find(comptime func: anytype) fn ([]@typeInfo(@TypeOf(func)).Fn.args[0].arg_type.?) ?@typeInfo(@TypeOf(func)).Fn.args[0].arg_type.? {
    return struct {
        fn call(arr: []@typeInfo(@TypeOf(func)).Fn.args[0].arg_type.?) ?@typeInfo(@TypeOf(func)).Fn.args[0].arg_type.? {
            for (arr) |cur|
                if (func(cur))
                    return cur;
            return null;
        }
    }.call;
}

pub fn findIndex(comptime func: anytype) fn ([]@typeInfo(@TypeOf(func)).Fn.args[0].arg_type.?) ?usize {
    return struct {
        fn call(arr: []@typeInfo(@TypeOf(func)).Fn.args[0].arg_type.?) ?usize {
            for (arr) |cur, idx|
                if (func(cur))
                    return idx;
            return null;
        }
    }.call;
}

test "Find" {
    const func = struct {
        fn call(value: u8) bool {
            return value == 'b';
        }
    }.call;
    const testFind = find(func);
    const testFindIndex = findIndex(func);

    var arr = [_]u8{'a', 'b', 'c'};
    std.testing.expectEqual(@as(u8, 'b'), testFind(&arr).?);
    std.testing.expectEqual(@as(usize, 1), testFindIndex(&arr).?);
}
