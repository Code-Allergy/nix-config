-- TODO --

local inactive_opacity = 0.9
local shadows_enabled = true
local workspace_swipe = true

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
    },

    render = {
        direct_scanout = 2,
    },

    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
        enforce_permissions = true
    },
})

