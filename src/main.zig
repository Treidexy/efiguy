const std = @import("std");
const uefi = std.os.uefi;
const gop = uefi.protocol.GraphicsOutput;
const L = std.unicode.utf8ToUtf16LeStringLiteral;

fn rgb(red: u8, green: u8, blue: u8) gop.BltPixel {
    return .{ .red = red, .green = green, .blue = blue, .reserved = 0 };
}

// pub fn efi_main(handle: efi.Handle, system_table: efi.tables.SystemTable) efi.Status {
pub fn main() void {
    const out = uefi.system_table.con_out.?;

    _ = out.reset(true);
    _ = out.outputString(L("Hello, world!\n"));

    const bs = uefi.system_table.boot_services.?;
    _ = bs.setWatchdogTimer(0, 0, 0, null);

    var gfx: *gop = undefined;
    _ = bs.locateProtocol(&gop.guid, null, @ptrCast(&gfx));

    const width = gfx.mode.info.horizontal_resolution;
    const height = gfx.mode.info.vertical_resolution;

    for (0..height) |y| {
        var pixel = [1]gop.BltPixel{rgb(@intFromFloat(255.0 / @as(f32, @floatFromInt(height)) * @as(f32, @floatFromInt(y))), 0, 0)};
        _ = gfx.blt(&pixel, .BltVideoFill, 0, 0, 0, y, width, 1, 0);
    }

    while (true) {}
}
