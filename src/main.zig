const std = @import("std");

const rl = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
});

const width: u32 = 480;
const height: u32 = 600;
const ground: u32 = 70;
const accel: f32 = 17.7;
var background: rl.Texture2D = undefined;
var player: [4]rl.Texture2D = undefined;
var player_vel: f32 = undefined;
var player_y: f32 = (height - ground) / 2;
var frame: f32 = 0;

var font: rl.Font = undefined;

pub fn setup() !void {
    rl.InitWindow(width, height, "Flappy");
    font = rl.LoadFont("res/LiberationMono-Regular.ttf");
    for (0..3) |i| {
        var fname: [64]u8 = undefined;
        _ = try std.fmt.bufPrintZ(&fname, "res/bird-{d}.png", .{i});
        var img = rl.LoadImage(&fname);
        rl.ImageResize(&img, 60, 60);
        player[i] = rl.LoadTextureFromImage(img);
    }
    background = rl.LoadTexture("res/background.png");
    rl.SetTargetFPS(30);
}

fn new_game() void {
    player_y = (height - ground) / 2;
    player_vel = -accel;
}

fn update() void {
    //const fr = rl.GetFrameTime();
    player_vel += 0.61; //* fr;

    player_y += player_vel;
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
}

fn draw() void {
    const f: usize = @intFromFloat(frame);
    rl.DrawTexture(background, 0, 0, rl.WHITE);
    rl.DrawTexture(player[@mod(f, 3)], 100, @intFromFloat(player_y), rl.WHITE);
}
pub fn main() !void {
    try setup();
    while (!rl.WindowShouldClose()) {
        //var time_str: [120]u8 = undefined;
        if (rl.IsKeyPressed(rl.KEY_SPACE)) {
            //const fr = rl.GetFrameTime();
            player_vel -= accel; // * fr;
        }
        rl.BeginDrawing();
        rl.ClearBackground(rl.BLACK);
        draw();
        rl.DrawFPS(5, 5);
        rl.EndDrawing();
        update();
    }
}
