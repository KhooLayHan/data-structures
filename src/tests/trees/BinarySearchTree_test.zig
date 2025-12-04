const std = @import("std");
const testing = std.testing;

const BinarySearchTree = @import("../../trees/BinarySearchTree.zig").BinarySearchTree;

test "BinarySearchTree insert() and contains()" {
    var tree = BinarySearchTree(i32).init(std.testing.allocator);
    defer tree.deinit();

    try tree.insert(50);
    try tree.insert(30);
    try tree.insert(70);
    try tree.insert(20);
    try tree.insert(40);

    try testing.expect(tree.contains(50));
    try testing.expect(tree.contains(20));
    try testing.expect(tree.contains(70));
    try testing.expect(tree.contains(30));
    try testing.expect(tree.contains(40));

    try testing.expect(!tree.contains(100));

    try testing.expectEqual(@as(usize, 5), tree.size);
}

test "BinarySearchTree no memory leaks" {
    var tree = BinarySearchTree(i32).init(std.testing.allocator);
    defer tree.deinit();

    var i: i32 = 0;
    while (i < 100) : (i += 1) {
        try tree.insert(i);
    }
}
