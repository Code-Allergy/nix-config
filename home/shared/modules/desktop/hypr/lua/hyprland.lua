-- TODO --

local inactive_opacity = 0.9
local shadows_enabled = true
local workspace_swipe = true

-- require("keybinds")
-- require("monitors")

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,

        col = {
            active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        -- # Set to true enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = true,

        -- # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = true,

        layout = "dwindle",
    },

    decoration = {
        rounding = 10,

        -- Change transparency of focused and unfocused windows
        active_opacity = 1.0,
        inactive_opacity = inactive_opacity,

        -- https://wiki.hyprland.org/Configuring/Variables/#blur
        blur = {
            -- high battery impact on mobile
            enabled = true
        },

        -- Drop shadows
        shadow = {
            enabled = shadows_enabled,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        }
    },

    -- https://wiki.hyprland.org/Configuring/Variables/#input
    input = {
        kb_layout = "us",
        follow_mouse = 1,

        -- -1.0 - 1.0, 0 means no modification.
        sensitivity = 0,

        touchpad = {
            natural_scroll = true,
            drag_lock = 0
        },
    },

    -- https://wiki.hyprland.org/Configuring/Variables/#gestures
    gestures = {
        workspace_swipe_touch = workspace_swipe
    },

    animations = {
        enabled = true
    },

    misc = {
        force_default_wallpaper = 0,
        vrr = 2,
        enable_swallow = true,
        swallow_regex = "^(kitty)$",
        font_family = "Montserrat",
    },

    dwindle = {
        preserve_split = true
    }
})

-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/
hl.device({
    name = "logitech-gaming-mouse-g502",
    accel_profile = "flat",
})

-- animations
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

-- other example curves
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })


hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin = 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })
