const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("ds-playground", .{
        .root_source_file = b.path("src/main.zig"),
    });

    // const mod = b.createModule("ds-playground", .{
    //     .root_source_file = b.path("src/main.zig"),
    //     .target = target,
    //     .optimize = optimize,
    // });

    // Static library
    const lib = b.addLibrary(.{
        .name = "ds-playground",
        .linkage = .static,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    lib.root_module.addLibraryPath(.{ .cwd_relative = "src/linear" });
    lib.root_module.addLibraryPath(.{ .cwd_relative = "src/trees" });
    lib.root_module.addLibraryPath(.{ .cwd_relative = "src/graphs" });
    lib.root_module.addLibraryPath(.{ .cwd_relative = "src/hash" });
    lib.root_module.addLibraryPath(.{ .cwd_relative = "src/algorithms" });
    lib.root_module.addLibraryPath(.{ .cwd_relative = "src/utils" });

    // Main executable for playing around
    const exe = b.addExecutable(.{
        .name = "ds-playground",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "ds-playground", .module = mod },
            },
        }),
    });
    exe.linkLibrary(lib);
    b.installArtifact(exe);

    // Run command
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run the playground");
    run_step.dependOn(&run_cmd.step);

    // Tests
    const test_step = b.step("test", "Run all tests");

    // Add all test files
    const test_files = [_][]const u8{
        // "tests/linear/array_list_test.zig",
        // "tests/linear/linked_list_test.zig",
        // "tests/trees/bst_test.zig",
        // "tests/algorithms/dijkstra_test.zig",
        "src/tests/trees/BinarySearchTree_test.zig",
        // Add more as you create them
    };

    for (test_files) |test_file| {
        const tests = b.addTest(.{
            .name = "ds-playground",
            .root_module = b.createModule(.{
                .root_source_file = b.path(test_file),
                .target = target,
                .optimize = optimize,
                .imports = &.{
                    .{ .name = "ds-playground", .module = mod },
                },
            }),
        });
        tests.linkLibrary(lib);

        const run_tests = b.addRunArtifact(tests);
        // run_tests.skip_foreign_checks = true;
        test_step.dependOn(&run_tests.step);
    }

    // Benchmarks
    // const bench_exe = b.addExecutable(.{
    //     .name = "benchmarks",
    //     .root_module = b.createModule(.{
    //         .root_source_file = b.path("benchmarks/benchmark_runner.zig"),
    //         .target = target,
    //         .optimize = .ReleaseFast,
    //     }),
    // });
    // const bench_run = b.addRunArtifact(bench_exe);
    // const bench_step = b.step("bench", "Run benchmarks");
    // bench_step.dependOn(&bench_run.step);

    // Examples
    // const examples = [_]struct { name: []const u8, src: []const u8 }{
    //     .{ .name = "bst-demo", .src = "examples/bst_demo.zig" },
    //     .{ .name = "dijkstra-demo", .src = "examples/dijkstra_demo.zig" },
    // };

    // for (examples) |ex| {
    //     const ex_exe = b.addExecutable(.{
    //         .name = ex.name,
    //         .root_module = b.createModule(.{
    //             .root_source_file = b.path(ex.src),
    //             .target = target,
    //             .optimize = optimize,
    //         }),
    //     });
    //     const ex_run = b.addRunArtifact(ex_exe);
    //     const ex_step = b.step(ex.name, b.fmt("Run {s} example", .{ex.name}));
    //     ex_step.dependOn(&ex_run.step);
    // }
}
