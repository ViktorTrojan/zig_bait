// Public utils
pub const addressToVtable = @import("zig_bait_tools").addressToVtable;

// The hook manager
pub const HookManager = @import("zig_bait/hook_manager.zig").HookManager;

test "hook manager tests" {
    @import("std").testing.refAllDecls(@import("zig_bait/hook_manager.zig"));
}
