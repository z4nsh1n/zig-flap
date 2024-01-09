const std = @import("std");

const rl = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
});

const width: u32 = 480;
const height: u32 = 600;
const ground: u32 = 80;
const accel: f32 = 21.7;
const gap: u32 = 220;
const pipe_width = 86;

var background: rl.Texture2D = undefined;
var pillar: rl.Texture2D = undefined;
var player: [4]rl.Texture2D = undefined;
var player_vel: f32 = undefined;
var player_y: f32 = (height - ground) / 2;

var pipe_x: [2]i32 = [2]i32{ width - 40, width - 40 };
var pipe_y: [2]f32 = [2]f32{ 0, 0 };

var frame: f32 = 0;
var rand: std.rand.Xoshiro256 = undefined;

var font: rl.Font = undefined;

pub fn setup() !void {
    //TODO make random init
    const w: u64 = @bitCast(std.time.milliTimestamp());
    //const w: u64 = @bitCast(std.time.timestamp());
    std.debug.print("timestamp: {d}\n", .{w});
    rand = std.rand.DefaultPrng.init(w);
    rl.InitWindow(width, height, "Flappy");

    // Load graphics stuff
    font = rl.LoadFont("res/LiberationMono-Regular.ttf");
    for (0..3) |i| {
        var fname: [64]u8 = undefined;
        _ = try std.fmt.bufPrintZ(&fname, "res/bird-{d}.png", .{i});
        var img = rl.LoadImage(&fname);
        rl.ImageResize(&img, 60, 60);
        player[i] = rl.LoadTextureFromImage(img);
    }
    background = rl.LoadTexture("res/background.png");
    pillar = rl.LoadTexture("res/pillar.png");

    rl.SetTargetFPS(40);
}

fn new_game() void {
    player_y = (height - ground) / 2;
    //player_vel = -accel;
    pipe_y[0] = @floatFromInt(random_pipe_height());
}

fn update() void {
    //const fr = rl.GetFrameTime();

    player_y += player_vel;
    player_vel += 0.61; //* fr;
    if (player_vel > 10.0) {
        frame = 0;
    } else {
        frame -= (player_vel - 10.0) * 0.03; //fancy animation
    }
    if (player_y > height - ground - 60) {
        @panic("Hit the ground");
    }
    // for(int i = 0; i < 2; i++)
    //         update_pipe(i);
    pipe_x[0] -= 5;
    if (pipe_x[0] <= -pipe_width) {
        pipe_x[0] = width - pipe_width;
        pipe_y[0] = @floatFromInt(random_pipe_height());
    }
}

fn draw() void {
    const f: usize = @intFromFloat(frame);
    rl.DrawTexture(background, 0, 0, rl.WHITE);

    const y2 = pipe_y[0] + gap;
    rl.DrawTexture(pillar, pipe_x[0], @intFromFloat(pipe_y[0] - height), rl.WHITE);
    rl.DrawTextureRec(pillar, rl.Rectangle{ .x = 0, .y = 0, .width = pipe_width, .height = height - y2 - ground }, rl.Vector2{ .x = @floatFromInt(pipe_x[0]), .y = y2 }, rl.WHITE);
    rl.DrawTexture(player[@mod(f, 3)], 100, @intFromFloat(player_y), rl.WHITE);
}

fn random_pipe_height() u64 {
    return (rand.next() % (height - ground - gap - 120) + 60);
}
pub fn main() !void {
    try setup();
    new_game();
    while (!rl.WindowShouldClose()) {
        //var time_str: [120]u8 = undefined;
        if (rl.IsKeyPressed(rl.KEY_SPACE)) {
            //const fr = rl.GetFrameTime();
            player_vel -= accel; // * fr;
            frame += 1.0;
        }
        rl.BeginDrawing();
        rl.ClearBackground(rl.BLACK);
        draw();
        rl.DrawFPS(5, 5);
        var b: [140]u8 = undefined;
        rl.DrawText(try std.fmt.bufPrintZ(&b, "{d:.4}", .{rand.next()}), 20, 20, 40, rl.RED);
        rl.EndDrawing();
        update();
    }
}
