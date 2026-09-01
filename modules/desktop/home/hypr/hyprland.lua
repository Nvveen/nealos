require('./monitors')

---------------------
---- MY PROGRAMS ----
---------------------
local programs = require('./programs')

-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function()
    hl.exec_cmd("noctalia")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("QT_QPA_PLATFORMTHEME", "kde")

-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

hl.config({
    ecosystem = {
        -- enforce_permissions = true,
        no_update_news = true,
        no_donation_nag = true
    }
})

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in = 0,
        gaps_out = 0,

        border_size = 2
    },

    decoration = {
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a
        },

        blur = {
            enabled = true,
            size = 3,
            passes = 2,
            vibrancy = 0.1696
        }
    }
})
-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        preserve_split = true -- You probably want this
    }
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "master"
    }
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
    scrolling = {
        fullscreen_on_one_column = true
    }
})

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = 0, -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = true -- If true disables the random hyprland logo / anime girl background. :(
    }
})

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false
        }
    }
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5
})

---------------------
---- KEYBINDINGS ----
---------------------

require('./bindings')

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name = "suppress-maximize-events",
    match = {
        class = ".*"
    },

    suppress_event = "maximize"
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false
    },

    no_focus = true
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
    name = "move-hyprland-run",
    match = {
        class = "hyprland-run"
    },

    move = "20 monitor_h-120",
    float = true
})

-- Noctalia Settings
hl.window_rule({
    match = {
        class = "dev.noctalia.Noctalia"
    },
    float = true,
    size = {1080, 920}
})

hl.layer_rule({
    name = "noctalia",
    match = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$"
    },
    no_anim = true,
    ignore_alpha = 0.5,
    blur = true,
    blur_popups = true
})

-- Colours come from noctalia's built-in Hyprland template, rendered to
-- ~/.config/hypr/noctalia.lua whenever the palette changes. It applies border
-- and group colours itself and returns the palette for our own use.
-- pcall because the file does not exist until noctalia has rendered once.
local cfgdir = os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config"
local ok, noctalia = pcall(dofile, cfgdir .. "/hypr/noctalia.lua")

if ok then
    noctalia.apply_theme()
else
    hl.notify("Noctalia theme not found, using default Hyprland theme", "error")
end
