const std = @import("std");

const option = @import("option/option.zig");

const tools = @import("zig_bait_tools");

/// The interface for hooking functions.
pub const Hook = struct {
    const Self = @This();

    /// The option for hooking.
    hook_option: option.Option,

    /// Initialize the interface.
    pub fn init(hook_option: option.Option) Self {
        const self = Self{
            .hook_option = hook_option,
        };

        return self;
    }

    /// Hook the function.
    pub fn doHook(self: *Self) !void {
        switch (self.hook_option) {
            inline else => |*opt| try opt.hook(opt),
        }
    }

    /// Restore the function.
    pub fn doRestore(self: *Self) void {
        switch (self.hook_option) {
            inline else => |*opt| opt.restore(opt),
        }
    }
};
