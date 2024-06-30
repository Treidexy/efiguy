const std = @import("std");

pub fn build(b: *std.Build) void {
    const efi = b.addExecutable(.{
        .name = "bootx64",
        .root_source_file = b.path("src/main.zig"),
        .target = b.resolveTargetQuery(.{
            .cpu_arch = .x86_64,
            .os_tag = .uefi,
            .abi = .msvc,
        }),
    });

    const wf = b.addWriteFiles();
    wf.addCopyFileToSource(efi.getEmittedBin(), "image/efi/boot/bootx64.efi");

    wf.step.dependOn(&efi.step);

    b.default_step.dependOn(&wf.step);

    const run = b.addSystemCommand(&.{ "qemu-system-x86_64", "-bios", "/usr/share/ovmf/x64/OVMF.fd", "-drive", "file=fat:rw:image,media=disk,format=raw" });
    run.step.dependOn(&wf.step);
    b.step("run", "builds and runs using qemu").dependOn(&run.step);
}
