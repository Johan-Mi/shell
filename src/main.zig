const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

fn show_prompt() !void {
    try std.io.getStdOut().writeAll("> ");
}

fn lex(line: []const u8, allocator: Allocator) !ArrayList([]const u8) {
    var token_iter = std.mem.tokenizeScalar(u8, line, ' ');
    var tokens = ArrayList([]const u8).init(allocator);
    while (token_iter.next()) |token| {
        try tokens.append(token);
    }
    return tokens;
}

fn interpret(tokens: []const []const u8, allocator: Allocator) !void {
    if (tokens.len != 0) {
        var child = std.process.Child.init(tokens, allocator);
        _ = try child.spawnAndWait();
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const is_interactive = std.os.isatty(std.os.STDIN_FILENO);

    while (true) {
        if (is_interactive) {
            try show_prompt();
        }

        var line = ArrayList(u8).init(allocator);
        defer line.deinit();
        std.io.getStdIn().reader().streamUntilDelimiter(line.writer(), '\n', null) catch return;

        var tokens = try lex(line.items, allocator);
        defer tokens.deinit();

        try interpret(tokens.items, allocator);
    }
}
