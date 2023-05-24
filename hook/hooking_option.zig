const fn_ptr = @import("fn_ptr/func_ptr.zig");
const VtablePointer = @import("vmt.zig").VtablePointer;

/// The options for the Virtual Method Table hook
pub const VmtOption = struct {
    /// The base pointer to the Virtual Function Table
    vtable: VtablePointer,
    /// The index of the function to be hooked
    index: usize,
    /// The target that should be hooked
    target: usize,
    /// The restore address. used internally.
    restore: ?usize,
    /// Whether to use debug logging, please referr to @This().enableDebug()
    debug: bool,
    /// Vtable length. Currently unused
    fn_length: ?usize,

    pub fn init(vtable: VtablePointer, index: usize, target: usize, fn_length: ?usize) VmtOption {
        return VmtOption{
            .vtable = vtable,
            .index = index,
            .target = target,
            .restore = null,
            .debug = false,
            .fn_length = fn_length,
        };
    }

    /// Sets a flag so that the whole hooking process prints debug messages to StdErr.
    pub fn enableDebug(self: *VmtOption) void {
        self.debug = true;
    }

    pub fn getOriginalFunction(self: VmtOption, hooked_func: anytype) anyerror!@TypeOf(hooked_func) {
        fn_ptr.checkIfFnPtr(hooked_func);

        if (self.restore) |restore| {
            return @intToPtr(@TypeOf(hooked_func), @ptrToInt(&restore));
        } else {
            return error.RestoreValueIsNull;
        }
    }
};

pub const HookingOption = union(enum) {
    vmt_option: VmtOption,
};
