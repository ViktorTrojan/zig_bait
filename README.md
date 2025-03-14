![logo](https://github.com/ViktorTrojan/zig_bait/blob/main/zig_bait.png?raw=true)

A native Hooking library with support for all common hooking mechanisms.
Detour & IAT hooks are not yet supported, but VMT are fully implemented.

If you have any ideas for how to automatically test this library, please let me know, considering
ASLR and the difference in possible multiple Compilers, i am not really sure how to effectively assure
this.

> Note: This is ment for zig **0.14.0**

## Usage:
### Install:
In your project just add the dependency to your Zig dependencies: `zig fetch --save git+https://github.com/ViktorTrojan/zig_bait`

And then in your `build.zig`:
```zig
const bait = b.dependency("zig_bait", .{});

your_project.root_module.addImport("bait", bait.module("zig_bait"));
```

### Using in your Project:
1. Make sure that your target uses the C calling convention. Implicitly `fastcall`, `stdcall` and all the ones
defined within Zig are supported.

```zig
// ...
const bait = @import("bait");
const HookManager = @import("bait").HookManager;

var hook_manager: HookManager = undefined;

fn hooked(abc: usize) callconv(.C) void {
  const original = hook_manager.getOriginalFunction(&hooked).?;

  std.debug.print("I am hooked {s}\n", .{ "on you ;)" });
  original(abc);
}

pub fn main() !void {
  const alloc = std.heap.page_allocator;
  hook_manager = HookManager.init(alloc);
  defer hook_manager.deinit();

  const victim_vtable: usize = @intFromPtr(getSymbolByName("your_target_func"));
  try hook_manager.append(
    bait.Method{
      .vmt = .{
        .object_address = victim_table,
        .positions = &.{ 1 },
        .targets = &.{ @intFromPtr(&hooked) },
      }
    }
  );
  try hook_manager.hookAll()
}
```
