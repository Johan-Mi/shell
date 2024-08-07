const std = @import("std");
const ArrayList = std.ArrayList;

const Self = @This();

const Token = []const u8;

source: []const u8,
tokens: std.ArrayList(Token),

pub fn lex(source: []const u8, allocator: std.mem.Allocator) !ArrayList(Token) {
    var lexer = Self{ .source = source, .tokens = ArrayList(Token).init(allocator) };
    return lexer.step();
}

fn step(self: *Self) !ArrayList(Token) {
    self.chomp();
    if (self.eat("|")) {
        try self.tokens.append("|");
    } else {
        const word = self.takeNone(" |") orelse return self.tokens;
        try self.tokens.append(word);
    }
    return @call(.always_tail, step, .{self});
}

fn chomp(self: *Self) void {
    self.source = std.mem.trimLeft(u8, self.source, &std.ascii.whitespace);
}

fn eat(self: *Self, str: []const u8) bool {
    if (!std.mem.startsWith(u8, self.source, str)) {
        return false;
    }
    self.source = self.source[str.len..];
    return true;
}

fn takeNone(self: *Self, values: []const u8) ?[]const u8 {
    const index = std.mem.indexOfAny(u8, self.source, values) orelse self.source.len;
    if (index == 0) {
        return null;
    } else {
        const slice = self.source[0..index];
        self.source = self.source[index..];
        return slice;
    }
}
