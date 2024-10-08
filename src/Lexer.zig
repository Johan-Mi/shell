const std = @import("std");

const Token = []const u8;

source: []const u8,

pub fn init(source: []const u8) @This() {
    return .{ .source = source };
}

pub fn next(self: *@This()) ?Token {
    const token = self.nextWithoutConsuming() orelse return null;
    self.source = self.source[token.len..];
    return token;
}

pub fn nextWithoutConsuming(self: *@This()) ?Token {
    const whitespace =
        std.mem.indexOfNone(u8, self.source, &std.ascii.whitespace) orelse self.source.len;
    self.source = self.source[whitespace..];

    if (std.mem.startsWith(u8, self.source, "|")) {
        return self.source[0.."|".len];
    } else {
        const word =
            std.mem.indexOfAny(u8, self.source, std.ascii.whitespace ++ "|") orelse self.source.len;
        return if (word == 0) null else self.source[0..word];
    }
}
