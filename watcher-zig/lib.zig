const std = @import("std");
const watcher = @cImport({
    @cInclude("wtr/watcher-c.h");
});
pub const Callback = *const fn (Event, ?*anyopaque) void;

path: [:0]const u8,
handle: ?*anyopaque,
callback: Callback,
data: ?*anyopaque,

const Self = @This();

pub fn init(
    path: [:0]const u8,
    cb: Callback,
    data: ?*anyopaque,
) Self {
    return Self{
        .path = path,
        .handle = null,
        .data = data,
        .callback = cb,
    };
}

pub fn deinit(self: *Self) !void {
    if (self.handle) |handle| {
        const err = watcher.wtr_watcher_close(handle);
        if (!err) {
            return error.WatcherCloseFailed; // Could be because the path is wrong
        }
    }
}

pub fn start(self: *Self) void {
    if (self.handle) |_| {
        return;
    }
    self.handle = watcher.wtr_watcher_open(self.path.ptr, callback, self);
}

fn callback(ev: watcher.struct_wtr_watcher_event, context: ?*anyopaque) callconv(.C) void {
    const self: *Self = @ptrCast(@alignCast(context));
    const event = Event.fromC(ev);
    self.callback(event, self.data);
}

pub const Event = struct {
    path: []const u8,
    associated_path: ?[]const u8,
    effect_type: EffectType,
    path_type: PathType,

    pub fn fromC(ev: watcher.struct_wtr_watcher_event) Event {
        return Event{
            .path = std.mem.span(ev.path_name),
            .associated_path = if (ev.associated_path_name == null) null else std.mem.span(ev.associated_path_name),
            .effect_type = @enumFromInt(ev.effect_type),
            .path_type = @enumFromInt(ev.path_type),
        };
    }
};

pub const EffectType = enum {
    rename,
    modify,
    create,
    destroy,
    owner,
    other,
};

pub const PathType = enum {
    dir,
    file,
    hard_link,
    sym_link,
    watcher,
    other,
};
