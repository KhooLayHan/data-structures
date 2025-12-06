const std = @import("std");

pub const BinarySearchTree = @import("trees/BinarySearchTree.zig").BinarySearchTree;
pub const LinkedList = @import("linear/LinkedList.zig").LinkedList;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // Quick testing/playing with your implementations
    std.debug.print("=== Data Structures Playground ===\n", .{});

    // Test whatever you're currently working on
    try testBST(allocator);
}

fn testBST(allocator: std.mem.Allocator) !void {
    var tree = BinarySearchTree(i32).init(allocator);
    defer tree.deinit();

    try tree.insert(50);
    try tree.insert(30);
    try tree.insert(70);

    std.debug.print("BST contains 30: {}\n", .{tree.contains(30)});
}
