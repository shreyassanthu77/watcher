const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "watcher",
        .target = target,
        .optimize = optimize,
    });
    lib.addIncludePath(b.path("./include/"));
    lib.addIncludePath(b.path("./watcher-c/include/"));
    lib.linkLibCpp();
    lib.addCSourceFiles(.{
        .root = b.path("./watcher-c/"),
        .files = &.{
            "./src/watcher-c.cpp",
        },
        .flags = &.{
            "-std=c++17",
            "-fPIC",
        },
    });
    lib.installHeadersDirectory(b.path("include"), ".", .{});
    lib.installHeadersDirectory(b.path("watcher-c/include"), ".", .{});

    b.installArtifact(lib);

    const module = b.addModule("watcher", .{
        .root_source_file = b.path("watcher-zig/lib.zig"),
    });
    module.linkLibrary(lib);
    module.addIncludePath(b.path("include"));
    module.addIncludePath(b.path("watcher-c/include"));
}
