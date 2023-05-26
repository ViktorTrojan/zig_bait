const Allocator = @import("std").mem.Allocator;

const fn_ptr = @import("fn_ptr/func_ptr.zig");
const AbstractClass = @import("vmt.zig").AbstractClass;

/// The options for the Virtual Method Table hook
pub const VmtOption = struct {
    /// The base class containing the targeted VTable
    base: AbstractClass,
    /// The index of the function to be hooked
    index: usize,
    /// The address to the hooked function
    target: usize,
    /// The restore address. used internally.
    restore: ?usize,
    /// Whether to use debug logging, please referr to @This().enableDebug()
    debug: bool,
    /// Whether the vtable shall be copied and the original pointer be redirected, or if only functions should be swapped
    shadow: bool,
    /// The allocator to be used when `shadow` is enabled
    alloc: ?Allocator,

    pub fn init(base: AbstractClass, index: usize, target: usize, shadow: bool, alloc: ?Allocator) VmtOption {
        return VmtOption{
            .base = base,
            .index = index,
            .target = target,
            .restore = null,
            .debug = false,
            .shadow = shadow,
            .alloc = alloc,
            .vtable_len = 0,
        };
    }

    /// Sets a flag so that the whole hooking process prints debug messages to StdErr.
    pub fn enableDebug(self: *VmtOption) void {
        self.debug = true;
    }

    pub fn getOriginalFunction(self: VmtOption, hooked_func: anytype) anyerror!@TypeOf(hooked_func) {
        fn_ptr.checkIfFnPtr(hooked_func);

        if (self.restore) |restore| {
            return @intToPtr(@TypeOf(hooked_func), restore);
        } else {
            return error.RestoreValueIsNull;
        }
    }
};

pub const HookingOption = union(enum) {
    vmt_option: VmtOption,
};
