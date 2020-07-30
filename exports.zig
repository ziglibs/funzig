const std = @import("std");

fn getFields(comptime args: anytype) []const std.builtin.TypeInfo.StructField {
    return @typeInfo(@TypeOf(args)).Struct.fields;
}

fn InputType(comptime fields: []const std.builtin.TypeInfo.StructField) type {
    return @typeInfo(fields[0].field_type).Fn.args[0].arg_type.?;
}

fn hasError(comptime fields: []const std.builtin.TypeInfo.StructField) bool {
    var has_error = false;
    comptime for (fields) |field| {
        if (@typeInfo(field.field_type).Fn.return_type) |ret| {
            if (@typeInfo(ret) == .ErrorUnion) {
                has_error = true;
            }
        }
    };
    return has_error;
}

fn Errorless(comptime t: type) type {
    var errless = t;
    if (@typeInfo(errless) == .ErrorUnion)
        errless = @typeInfo(errless).ErrorUnion.payload;
    return errless;
}

fn ReturnType(comptime fields: []const std.builtin.TypeInfo.StructField) type {
    var has_error = hasError(fields);

    var errless = Errorless(@typeInfo(fields[fields.len - 1].field_type).Fn.return_type.?);
    return if (has_error) anyerror!errless else errless;
}

pub fn pipe(comptime args: anytype) fn (InputType(getFields(args))) ReturnType(getFields(args)) {
    if (@typeInfo(@TypeOf(args)) != .Struct)
        @compileError("Expected tuple, found " ++ @typeName(@TypeOf(args)));
    
    const fields = getFields(args);
    
    const input_type = InputType(fields);
    const return_type = ReturnType(fields);

    return struct {
        inline fn call_(comptime index: usize, input: @typeInfo(fields[index].field_type).Fn.args[0].arg_type.?) if (hasError(fields)) anyerror!Errorless(@typeInfo(fields[index].field_type).Fn.return_type.?) else @typeInfo(fields[index].field_type).Fn.return_type.? {
            return if (index + 1 == fields.len)
                args[index](input)
            else
                return call_(index + 1, args[index](input));
        }

        fn call (input: input_type) return_type {
            return call_(0, input);
        }
    }.call;
}
