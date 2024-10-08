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
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const is_interactive = std.io.getStdIn().isTty();

    var line = ArrayList(u8).init(allocator);
    defer line.deinit();

    var tokens = ArrayList([]const u8).init(allocator);
    defer tokens.deinit();

    while (true) {
        if (is_interactive) {
            try showPrompt();
        }

        line.clearRetainingCapacity();
        std.io.getStdIn().reader().streamUntilDelimiter(line.writer(), '\n', null) catch return;

        tokens.clearRetainingCapacity();
        var lexer = @import("Lexer.zig").init(line.items);
        while (lexer.next()) |token| try tokens.append(token);

        try interpret(tokens.items, allocator);
    }
}
