const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

fn showPrompt() !void {
    try std.io.getStdOut().writeAll("> ");
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

    var line = ArrayList(u8).init(allocator);
    defer line.deinit();

    while (true) {
        if (is_interactive) {
            try showPrompt();
        }

        line.clearRetainingCapacity();
        std.io.getStdIn().reader().streamUntilDelimiter(line.writer(), '\n', null) catch return;

        var tokens = try @import("Lexer.zig").lex(line.items, allocator);
        defer tokens.deinit();

        try interpret(tokens.items, allocator);
    }
}
