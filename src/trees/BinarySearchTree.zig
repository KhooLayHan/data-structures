const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn BinarySearchTree(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            value: T,
            left: ?*Node,
            right: ?*Node,
        };

        allocator: Allocator,
        root: ?*Node,
        size: usize,

        pub fn init(allocator: Allocator) Self {
            return .{
                .allocator = allocator,
                .root = null,
                .size = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            if (self.root) |root| {
                self.destroyNode(root);
            }
        }

        pub fn destroyNode(self: *Self, node: *Node) void {
            if (node.left) |left| {
                self.destroyNode(left);
            }

            if (node.right) |right| {
                self.destroyNode(right);
            }

            self.allocator.destroy(node);
        }

        pub fn insert(self: *Self, value: T) !void {
            if (self.root) |root| {
                try self.insertNode(root, value);
            } else {
                self.root = try self.createNode(value);
            }

            self.size += 1;
        }

        fn createNode(self: *Self, value: T) !*Node {
            const node = try self.allocator.create(Node);

            node.* = .{
                .value = value,
                .left = null,
                .right = null,
            };

            return node;
        }

        fn insertNode(self: *Self, node: *Node, value: T) !void {
            if (value < node.value) {
                if (node.left) |left| {
                    try self.insertNode(left, value);
                } else {
                    node.left = try self.createNode(value);
                }
            } else {
                if (node.right) |right| {
                    try self.insertNode(right, value);
                } else {
                    node.right = try self.createNode(value);
                }
            }
        }

        pub fn contains(self: Self, value: T) bool {
            return self.root != null and self.containsNode(self.root.?, value);
        }

        fn containsNode(self: Self, node: *Node, value: T) bool {
            if (value == node.value) {
                return true;
            }

            if (value < node.value) {
                if (node.left) |left| {
                    return self.containsNode(left, value) orelse return false;
                }
            } else {
                if (node.right) |right| {
                    return self.containsNode(right, value) orelse return false;
                }
            }
        }
    };
}
