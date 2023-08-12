const std = @import("std");
const stdout = std.io.getStdOut().writer();
const print = std.debug.print;

const w = 88;
const h = 17;
const size = w * h;
const cubeWidth = 10;
const vOffset = 44;
const hOffset = 8;

var a: f32 = 0.0;
var b: f32 = 0.0;
var c: f32 = 0.0;
var ooz: f32 = 0.0;
var matrix: [size]u8 = .{'.'} ** size;
var buffer: [size]f32 = .{0} ** size;

fn calcX(i: f32, j: f32, k: f32) f32 {
    return j * @sin(a) * @sin(b) * @cos(c)
         - k * @cos(a) * @sin(b) * @cos(c)
         + j * @cos(a) * @sin(c)
         + k * @sin(a) * @sin(c)
         + i * @cos(b) * @cos(c);
}

fn calcY(i: f32, j: f32, k: f32) f32 {
    return j * @cos(a) * @cos(c)
         + k * @sin(a) * @cos(c)
         - j * @sin(a) * @sin(b) * @sin(c)
         + k * @cos(a) * @sin(b) * @sin(c)
         - i * @cos(b) * @sin(c);
}

fn calcZ(i: f32, j: f32, k: f32) f32 {
    return k * @cos(a) * @cos(b)
         - j * @sin(a) * @cos(b)
         + i * @sin(b);
}

fn calc(i: f32, j: f32, k: f32, ch: u8) void {
    const distanceFromView = 100;
    var x_ = calcX(i, j, k);
    var y_ = calcY(i, j, k);
    var z_ = calcZ(i, j, k) + distanceFromView;

    ooz = 1 / z_;

    // var x: i32 = @intFromFloat(x_ + vOffset);
    // var y: i32 = @intFromFloat(@divTrunc(y_, 2) + hOffset);

    var x: i32 = @intFromFloat(w / 2 + hOffset + 40 * ooz * x_ * 2);
    var y: i32 = @intFromFloat(h / 2 + 40 * ooz * y_);

    var id: usize = @intCast(x + y * w);

    if(id >= 0 and id < size) {
        if(ooz > buffer[id]) {
            buffer[id] = ooz;
            matrix[id] = ch;
        }
    }
}

fn cube(i: f32, j: f32, k: f32) void {
    calc(i, j, k, '#');
    calc(k, j, i, '@');
    calc(-k, j, i, '+');
    calc(-i, j, k, '&');
    calc(i, -k, j, '*');
    calc(i, k, j, '-');
}

fn cube2(i: f32, j: f32, k: f32) void {
    calc(i, j, -k, '@');
    calc(k, j, i, '$');
    calc(-k, j, -i, '~');
    calc(-i, j, k, '#');
    calc(i, -k, -j, ';');
    calc(i, k, j, '+');
}

pub fn main() !void {
    var breakLn: i32 = 0;
    const inc = 0.6;
    try stdout.print("\x1b[2J", .{});
    while(true) {
        matrix = .{' '} ** size;
        buffer = .{0} ** size;
        var i: f32 = -cubeWidth;
        while (i < cubeWidth) : (i += inc) {
            var j: f32 = -cubeWidth;
            while (j < cubeWidth) : (j += inc) {
                cube(i, j, cubeWidth);
                // cube2(i,j,cubeWidth);
            }
        }

        try stdout.print("\x1b[H", .{});

        for (matrix) |it| {
            if (breakLn == 88) {
                try stdout.print("\n", .{});
                breakLn = 0;
            }
            try stdout.print("{c}", .{it});
            breakLn += 1;
        }

        a += 0.05;
        b += 0.05;
        c += 0.02;
        std.time.sleep(16000 * 1000);
    }
}
