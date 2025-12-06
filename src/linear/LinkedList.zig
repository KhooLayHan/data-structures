const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn LinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            data: T,
            next: ?*Node,
        };

        allocator: Allocator,
        head: ?*Node,
        tail: ?*Node,
        size: usize,

        pub fn init(allocator: Allocator) Self {
            return .{
                .allocator = allocator,
                .head = null,
                .tail = null,
                .size = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            var current = self.head;

            while (current) |node| {
                const next = node.next;
                self.allocator.destroy(node);
                current = next;
            }

            self.head = null;
            self.tail = null;
            self.size = 0;
        }

        fn createNode(self: *Self, data: T) !*Node {
            const node = try self.allocator.create(Node);

            node.* = .{
                .data = data,
                .next = null,
            };

            return node;
        }

        pub fn prepend(self: *Self, data: T) !void {
            const node = try self.createNode(data);

            if (self.head) |head| {
                node.next = head;
                self.head = node;
            } else {
                self.head = node;
                self.tail = node;
            }

            self.size += 1;
        }

        pub fn append(self: *Self, data: T) !void {
            const node = try self.createNode(data);

            if (self.tail) |tail| {
                tail.next = node;
                self.tail = node;
            } else {
                self.head = node;
                self.tail = node;
            }

            self.size += 1;
        }

        pub fn insert(self: *Self, index: usize, data: T) !void {
            if (index > self.size) return error.IndexOutOfBounds;

            if (index == 0) {
                return self.prepend(data);
            }

            if (index == self.size) {
                return self.append(data);
            }

            const node = try self.createNode(data);

            var current = self.head.?;
            var i: usize = 0;

            while (i < index - 1) : (i += 1) {
                current = current.next.?;
            }

            node.next = current.next;
            current.next = node;
            self.size += 1;
        }

        pub fn popFront(self: *Self) ?T {
            const head = self.head orelse return null;

            const data = head.data;
            self.head = head.next;

            if (self.head == null) {
                self.tail = null;
            }

            self.allocator.destroy(head);
            self.size -= 1;

            return data;
        }

        pub fn popBack(self: *Self) ?T {
            if (self.head == null) return null;

            if (self.head.? == self.tail.?) {
                const data = self.head.?.data;

                self.allocator.destroy(self.head.?);

                self.head = null;
                self.tail = null;
                self.size -= 1;

                return data;
            }

            var current = self.head.?;

            while (current.next.? != self.tail.?) {
                current = current.next.?;
            }

            const data = self.tail.?.data;

            self.allocator.destroy(self.tail.?);

            current.next = null;
            self.tail = current;
            self.size -= 1;

            return data;
        }

        pub fn removeAt(self: *Self, index: usize) !T {
            if (index >= self.size) return error.IndexOutOfBounds;

            if (index == 0) {
                return self.popFront() orelse error.EmptyList;
            }

            var current = self.head.?;
            var i: usize = 0;

            while (i < index - 1) : (i += 1) {
                current = current.next.?;
            }

            const to_remove = current.next.?;
            const data = to_remove.data;

            current.next = to_remove.next;

            if (to_remove == self.tail.?) {
                self.tail = current;
            }

            self.allocator.destroy(to_remove);
            self.size -= 1;

            return data;
        }

        pub fn remove(self: *Self, value: T) bool {
            if (self.head == null) return false;

            if (self.head.?.data == value) {
                _ = self.popFront();
                return true;
            }

            var current = self.head.?;

            while (current.next) |next| {
                if (next.data == value) {
                    current.next = next.next;

                    if (next == self.tail.?) {
                        self.tail = current;
                    }

                    self.allocator.destroy(next);
                    self.size -= 1;

                    return true;
                }

                current = next;
            }

            return false;
        }

        pub fn get(self: Self, index: usize) !T {
            if (index >= self.size) return error.IndexOutOfBounds;

            var current = self.head.?;
            var i: usize = 0;

            while (i < index) : (i += 1) {
                current = current.next.?;
            }

            return current.data;
        }

        pub fn getPtr(self: Self, index: usize) !*T {
            if (index >= self.size) return error.IndexOutOfBounds;

            var current = self.head.?;
            var i: usize = 0;

            while (i < index) : (i += 1) {
                current = current.next.?;
            }

            return &current.data;
        }

        pub fn contains(self: Self, value: T) bool {
            var current = self.head;

            while (current) |node| {
                if (node.data == value) return true;
                current = node.next;
            }

            return false;
        }

        pub fn peekFront(self: Self) ?T {
            return if (self.head) |head| head.data else null;
        }

        pub fn peekBack(self: Self) ?T {
            return if (self.tail) |tail| tail.data else null;
        }

        pub fn isEmpty(self: *Self) bool {
            return self.size == 0;
        }

        pub fn clear(self: *Self) void {
            self.deinit();
            self.* = Self.init(self.allocator);
        }

        pub fn reverse(self: *Self) void {
            if (self.head == null) return;

            var previous: ?*Node = null;
            var current = self.head;
            self.tail = self.head;

            while (current) |node| {
                const next = node.next;

                node.next = previous;
                previous = node;
                current = next;
            }

            self.head = previous;
        }
    };
}
