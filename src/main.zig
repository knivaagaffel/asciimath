const std = @import("std");
const symbols = @import("symbols.zig");
const unicode = @import("std").unicode;

const writer = std.io.bufferedWriter(std.io.getStdOut());
var args = std.process.args;

pub fn main() void {
    std.debug.print("Hello, World!\n", .{});
}

const width: u16 = 20;
const height: u16 = 10;

const Vec2 = struct {
    x: u16,
    y: u16,
};

const Range2D = struct {
    rows: Vec2,
    cols: Vec2,
};

// above and below are the same for all children
// but their meaning is different for each type
// matrix: above is the row above, below is the row below
// next: is the next column. if a matrix has 2 columns, then the next is chosen to be the closest row to the center
// that means the las element in that row
// matrix is recursivly defied so a 4x.. matrix is a matrix of 2 2x.. matrices
// fraction: above is the numerator, below is the denominator
// summation: above is the upper limit, below is the lower limit
// integral: above is upper limit, below is lower limit
// symbol: above is the superscript, below is the subscript
const NodeType = enum {
    Integral,
    Summation,
    Matrix,
    Fraction,
    Symbol,
    Expression,
};

const Node = struct {
    above: ?*Node = null,
    next: ?*Node = null,
    below: ?*Node = null,
    type: NodeType = NodeType.Symbol,
    current: isize = 0,
};

const Matrix = struct {
    rows: []Node = undefined,
    next: ?*Node = null,
};

test "matrix2x2" {

    // const allocator = std.heap.page_allocator;
    // var arena = std.heap.ArenaAllocator.init(allocator);
    // defer arena.deinit();
    // const nodes = try arena.allocator().alloc(Node, 16);

    var matrix = Matrix{};
    var a = Node{};
    var b = Node{};
    var c = Node{};
    var frac = Node{};
    var d = Node{};
    var e = Node{};
    var f = Node{};
    var g = Node{};
    frac.above = &d;
    frac.below = &e;
    a.next = &b;
    // while reading this we get a line width of 1
    c.next = &frac;
    // line width of 3
    f.next = &g;
    // line width of 1
    // total = 5
    // add padding
    // --> 7
    a.current = 3;
    c.current = 0;
    f.current = -3;
    var rows = [_]Node{ a, c, f };
    matrix.rows = &rows;
    draw_matrix(matrix);
    try std.testing.expect(true);
}

fn draw_matrix(self: Matrix) void {
    var rows = self.rows;
    const num_rows = self.rows.len;
    var padding = false;
    for (0..num_rows) |i| {
        const lines = get_num_lins(&rows[i]);
        std.debug.print("lines: {}\n", .{lines});
        if (lines > 1) {
            std.debug.print("need to add padding around this line\n", .{});
            padding = true;
        }
        print_line(rows[i]);
    }
}

fn parse_matrix() void {
    const row_width: usize = undefined;
    _ = row_width;
    // set the root of all rows to the correct line
}

fn print_line(node: Node) void {
    std.debug.print("o", .{});
    std.debug.print("{}", .{node.current});
    if (node.above != null) {
        print_line(node.above.?.*);
    }
    if (node.below != null) {
        print_line(node.below.?.*);
    }
    if (node.next != null) {
        print_line(node.next.?.*);
    } else {}
}

fn get_num_lins(node: *Node) u16 {
    var count: u16 = 1;
    if (node.above != null) {
        count += get_num_lins(node.above.?);
    }
    if (node.below != null) {
        count += get_num_lins(node.below.?);
    }
    if (node.next != null) {
        const count_next = get_num_lins(node.next.?);
        if (count_next > count) {
            count = count_next;
        }
    }
    return count;
}

// notes
// The fundamental units is lines, lines have height and width, and can contain other lines. For example a line starts out simple with a single symbol
// but if we encounter a fraction we need to add two additional lines to the current line. On each split we make a recursive call to the draw function with the
// new line. This is the same for sub/superscript, and matrices. The only difference is that fractions have a line above and below the line, while sub/superscript
// have a line above or below the line. Matrices have multiple lines above and below the line.
// matrix and fractions and sub/supscript should be handled with recursion, they share the fact that they have multiple lines that need to be centered for
// them selves
// this makes a graph of lines, where each line can have multiple children, and each child can have multiple children. The graph is a tree, where the root is the
// main line. e.g the entire expression. only matrices can center itself. fractions have to retain the same width as the parent line.
//
//
//                    child----------------
//                    |                   |-   child
//                    |
//             child ----------------------------
//     root -------------------------------------
//             child ----------------------------
