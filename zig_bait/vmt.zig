const std = @import("std");
const builtin = @import("builtin");
const win = std.os.windows;
const lin = std.os.linux;

const tools = @import("zig_bait_tools");
const interface = @import("interface.zig");
const option = @import("option/option.zig");

const Allocator = std.mem.Allocator;

fn hook(opt: *option.vmt.Option) anyerror!void {
    const ptr = tools.Address.init(opt.base.*);
    const new_flags = tools.getFlags(tools.Flags.readwrite);

    for (opt.index_map) |*map| {
        const old = try tools.setNewProtect(ptr, map.position, new_flags) orelse tools.getFlags(tools.Flags.read);
        defer _ = tools.setNewProtect(ptr, map.position, old) catch {};
        map.restore = opt.base.*[map.position];
        opt.base.*[map.position] = map.target;
    }
}

fn restore(opt: *option.vmt.Option) void {
    for (opt.index_map) |map| {
        opt.base.*[map.position] = map.restore.?;
        hook(opt) catch @panic("Restoring the original vtable failed.");
    }
}

pub fn init(alloc: Allocator, base_class: tools.AbstractClass, positions: []const usize, targets: []const usize) !interface.Hook {
    const opt = try option.vmt.Option.init(alloc, base_class, positions, targets, &hook, &restore);
    const self = interface.Hook.init(option.Option{ .vmt = opt });
    return self;
}
