local programs = require('./programs')

local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local ipc = "noctalia msg "

local directionKeys = {
    left = "H",
    right = "L",
    up = "K",
    down = "J"
}

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more

-- 1. General
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(programs.terminal), {
    description = "Open Terminal"
})
hl.bind(mainMod .. " + Q", hl.dsp.window.close(), {
    description = "Close Window"
})
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({
    mode = "fullscreen"
}), {
    description = "Full Screen"
})
hl.bind(mainMod .. " + ALT + F", hl.dsp.window.fullscreen({
    mode = "maximized"
}), {
    description = "Full Width"
})
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(programs.fileManager), {
    description = "Open File Manager"
})
hl.bind(mainMod .. " + V", hl.dsp.window.float({
    action = "toggle"
}), {
    description = "Toggle Float"
})
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo(), {
    description = "Toggle Pseudo"
})
hl.bind(mainMod .. " + T", hl.dsp.layout("togglesplit"), {
    description = "Toggle Split Layout"
}) -- dwindle only
-- Noctalia
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"), {
    description = "Toggle Launcher"
})
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"), {
    description = "Toggle Control Center"
})
hl.bind(mainMod .. " + Comma", hl.dsp.exec_cmd(ipc .. "settings-toggle"), {
    description = "Toggle Settings"
})
hl.bind("ALT + Tab", hl.dsp.exec_cmd(ipc .. "window-switcher"), {
    description = "Window Switcher"
})
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(ipc .. "panel-toggle blackbartblues/keymap:panel && " .. ipc ..
                                               "plugin blackbartblues/keymap:panel all view-list"), {
    description = "Toggle Keymap Panel"
})
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(ipc .. "panel-toggle noctalia/notes:panel"), {
    description = "Toggle Notes Panel"
})
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd(ipc .. "panel-toggle session"), {
    description = "Toggle Session Panel"
})

-- 2. Window Focus
hl.bind(mainMod .. " + " .. directionKeys.left, hl.dsp.focus({
    direction = "left"
}), {
    description = "Focus Left"
})
hl.bind(mainMod .. " + " .. directionKeys.right, hl.dsp.focus({
    direction = "right"
}), {
    description = "Focus Right"
})
hl.bind(mainMod .. " + " .. directionKeys.up, hl.dsp.focus({
    direction = "up"
}), {
    description = "Focus Up"
})
hl.bind(mainMod .. " + " .. directionKeys.down, hl.dsp.focus({
    direction = "down"
}), {
    description = "Focus Down"
})

-- 3. Window Swap
hl.bind(mainMod .. " + SHIFT + " .. directionKeys.left, hl.dsp.window.swap({
    direction = "l"
}), {
    description = "Swap Window Left"
})
hl.bind(mainMod .. " + SHIFT + " .. directionKeys.down, hl.dsp.window.swap({
    direction = "d"
}), {
    description = "Swap Window Down"
})
hl.bind(mainMod .. " + SHIFT + " .. directionKeys.up, hl.dsp.window.swap({
    direction = "u"
}), {
    description = "Swap Window Up"
})
hl.bind(mainMod .. " + SHIFT + " .. directionKeys.right, hl.dsp.window.swap({
    direction = "r"
}), {
    description = "Swap Window Right"
})

-- 4. Window Resizing
hl.bind(mainMod .. " + CTRL + " .. directionKeys.left, hl.dsp.window.resize({
    direction = "l",
    x = -25,
    y = 0,
    relative = true
}), {
    description = "Resize Window Left"
})
hl.bind(mainMod .. " + CTRL + " .. directionKeys.down, hl.dsp.window.resize({
    direction = "d",
    x = 0,
    y = 25,
    relative = true
}), {
    description = "Resize Window Down"
})
hl.bind(mainMod .. " + CTRL + " .. directionKeys.up, hl.dsp.window.resize({
    direction = "u",
    x = 0,
    y = -25,
    relative = true
}), {
    description = "Resize Window Up"
})
hl.bind(mainMod .. " + CTRL + " .. directionKeys.right, hl.dsp.window.resize({
    direction = "r",
    x = 25,
    y = 0,
    relative = true
}), {
    description = "Resize Window Right"
})
hl.bind(mainMod .. " + CTRL + ALT + " .. directionKeys.left, hl.dsp.window.resize({
    direction = "l",
    x = -100,
    y = 0,
    relative = true
}), {
    description = "Resize Window Left Fast"
})
hl.bind(mainMod .. " + CTRL + ALT + " .. directionKeys.down, hl.dsp.window.resize({
    direction = "d",
    x = 0,
    y = 100,
    relative = true
}), {
    description = "Resize Window Down Fast"
})
hl.bind(mainMod .. " + CTRL + ALT + " .. directionKeys.up, hl.dsp.window.resize({
    direction = "u",
    x = 0,
    y = -100,
    relative = true
}), {
    description = "Resize Window Up Fast"
})
hl.bind(mainMod .. " + CTRL + ALT + " .. directionKeys.right, hl.dsp.window.resize({
    direction = "r",
    x = 100,
    y = 0,
    relative = true
}), {
    description = "Resize Window Right Fast"
})
hl.bind(mainMod .. " + CTRL + ALT + SHIFT + " .. directionKeys.left, hl.dsp.window.resize({
    direction = "l",
    x = -300,
    y = 0,
    relative = true
}), {
    description = "Resize Window Left Very Fast"
})
hl.bind(mainMod .. " + CTRL + ALT + SHIFT + " .. directionKeys.down, hl.dsp.window.resize({
    direction = "d",
    x = 0,
    y = 300,
    relative = true
}), {
    description = "Resize Window Down Very Fast"
})
hl.bind(mainMod .. " + CTRL + ALT + SHIFT + " .. directionKeys.up, hl.dsp.window.resize({
    direction = "u",
    x = 0,
    y = -300,
    relative = true
}), {
    description = "Resize Window Up Very Fast"
})
hl.bind(mainMod .. " + CTRL + ALT + SHIFT + " .. directionKeys.right, hl.dsp.window.resize({
    direction = "r",
    x = 300,
    y = 0,
    relative = true
}), {
    description = "Resize Window Right Very Fast"
})

-- 5. Workspace Management
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.focus({
        workspace = i
    }), {
        description = "Switch to Workspace " .. i
    })
    hl.bind(mainMod .. " + " .. key, hl.dsp.window.move({
        workspace = i
    }), {
        description = "Move Window to Workspace " .. i
    })
end

hl.bind(mainMod .. " + G", hl.dsp.group.toggle(), {
    description = "Toggle window grouping"
})
hl.bind(mainMod .. " + ALT + G", hl.dsp.window.move({
    out_of_group = true
}), {
    description = "Move active window out of group"
})

hl.bind(mainMod .. " + ALT + LEFT", hl.dsp.window.move({
    into_group = "l"
}), {
    description = "Move window to group on left"
})
hl.bind(mainMod .. " + ALT + RIGHT", hl.dsp.window.move({
    into_group = "r"
}), {
    description = "Move window to group on right"
})
hl.bind(mainMod .. " + ALT + UP", hl.dsp.window.move({
    into_group = "u"
}), {
    description = "Move window to group on top"
})
hl.bind(mainMod .. " + ALT + DOWN", hl.dsp.window.move({
    into_group = "d"
}), {
    description = "Move window to group on bottom"
})

hl.bind(mainMod .. " + ALT + TAB", hl.dsp.group.next(), {
    description = "Next window in group"
})
hl.bind(mainMod .. " + ALT + SHIFT + TAB", hl.dsp.group.prev(), {
    description = "Previous window in group"
})

hl.bind(mainMod .. " + CTRL + LEFT", hl.dsp.group.prev(), {
    description = "Move grouped window focus left"
})
hl.bind(mainMod .. " + CTRL + RIGHT", hl.dsp.group.next(), {
    description = "Move grouped window focus right"
})

hl.bind(mainMod .. " + ALT + mouse_down", hl.dsp.group.next(), {
    description = "Next window in group"
})
hl.bind(mainMod .. " + ALT + mouse_up", hl.dsp.group.prev(), {
    description = "Previous window in group"
})

for index = 1, 5 do
    hl.bind(mainMod .. " + ALT + code:" .. tostring(index + 9), hl.dsp.group.active({
        index = index
    }), {
        description = "Switch to group window " .. index
    })
end

-- 6. Special Workspaces (Scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("scratchpad"), {
    description = "Toggle scratchpad workspace"
})
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({
    workspace = "special:scratchpad"
}), {
    description = "Move window to scratchpad workspace"
})

-- 7. Scroll Through Workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({
    workspace = "e+1"
}), {
    description = "Next Workspace"
})
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({
    workspace = "e-1"
}), {
    description = "Previous Workspace"
})

-- 8. Move/Resize Windows with Mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), {
    mouse = true,
    description = "Drag Window"
})
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), {
    mouse = true,
    description = "Resize Window"
})

-- 9. Laptop Multimedia Keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. "volume-up"), {
    description = "Raise Volume"
})
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. "volume-down"), {
    description = "Lower Volume"
})
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. "volume-mute"), {
    description = "Mute Volume"
})
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. "brightness-up"), {
    description = "Increase Brightness"
})
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. "brightness-down"), {
    description = "Decrease Brightness"
})
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), {
    description = "Next Track",
    locked = true
})
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), {
    description = "Pause",
    locked = true
})
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), {
    description = "Play",
    locked = true
})
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), {
    description = "Previous Track",
    locked = true
})

-- hl.bind(mainMod .. " + M",
--     hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"), {
--         description = "Open Hyprland Menu"
--     })
