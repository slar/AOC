const std = @import("std");

// Struct checking if a sequence of characters matches a number
const Number = struct {
    num: u8,
    str: []const u8,
    matched: u8 = 0,

    fn matches(this: *@This(), ch: u8) bool {
        // Matches number
        if (ch == this.num) {
            this.matched = 0;
            return true;
        }
        if (this.str[this.matched] != ch) {
            // Character doesn't match word
            if (this.str[0] == ch) {
                // Character matches start of a word
                this.matched = 1;
            } else {
                // Character doesn't match beginning of word
                this.matched = 0;
            }
            return false;
        } else {
            // Character matches partial or full word
            this.matched += 1;
        }
        if (this.str.len == this.matched) {
            // Matches full word
            this.matched = 0;
            return true;
        }
        // Not a full match
        return false;
    }

    fn number(this: @This()) u8 {
        return this.num - '0';
    }

    fn reset(this: *@This()) void {
        this.matched = 0;
    }
};

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const stdin = std.io.getStdIn();
    var input = std.ArrayList(u8).init(allocator);
    defer input.deinit();

    var numbers: [10]Number = .{
        .{ .num = '0', .str = "zero" },
        .{ .num = '1', .str = "one" },
        .{ .num = '2', .str = "two" },
        .{ .num = '3', .str = "three" },
        .{ .num = '4', .str = "four" },
        .{ .num = '5', .str = "five" },
        .{ .num = '6', .str = "six" },
        .{ .num = '7', .str = "seven" },
        .{ .num = '8', .str = "eight" },
        .{ .num = '9', .str = "nine" },
    };

    var total: i32 = 0;

    while (true) {
        if (stdin.reader().streamUntilDelimiter(input.writer(), '\n', 1024) == error.EndOfStream)
            break;
        var first: ?i32 = null;
        var last: i32 = 0;
        for (input.items) |item| {
            for (&numbers) |*number| {
                if (number.matches(item)) {
                    if (first == null) {
                        first = number.number();
                    }
                    last = number.number();
                }
            }
        }
        var linesum: i32 = 0;
        if (first) |f| {
            linesum = (f * 10) + last;
        }
        total += linesum;

        std.log.debug("{s} = {}", .{ input.items, linesum });
        // Clear any partial matches
        for (&numbers) |*number| {
            number.reset();
        }
        input.clearRetainingCapacity();
    }
    std.log.info("Total: {}", .{total});
}

test "simple test" {
    var nine = Number{ .num = '9', .str = "nine" };
    try std.testing.expect(nine.matches('9'));
    try std.testing.expect(!nine.matches('8'));
    try std.testing.expect(!nine.matches('n'));
    try std.testing.expect(!nine.matches('i'));
    try std.testing.expect(!nine.matches('n'));
    try std.testing.expect(nine.matches('e'));
    try std.testing.expect(!nine.matches('n'));
    try std.testing.expect(!nine.matches('i'));
    try std.testing.expect(!nine.matches('n'));
    try std.testing.expect(nine.matches('e'));
}
