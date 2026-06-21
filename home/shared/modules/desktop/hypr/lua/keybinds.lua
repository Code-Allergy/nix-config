-- TODO: lua --


-- TODO: move to a new file
local terminal = "kitty"
local fileManager = "dolphin"
local appRunner = "fuzzel"

local mainMod = "SUPER"
local resizeStep = 50

hl.bind("CTRL + ALT + T", hl.dsp.exec_cmd("uwsm app -- " .. terminal))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(appRunner))
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("uwsm app -- " .. fileManager))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("togglefloating"))

hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())         -- dwindle
hl.bind(mainMod .. " + TAB", hl.dsp.layout("togglesplit")) -- dwindle only

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })


-- Move focus with mainMod + vim binds
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- # Resize with vim motions + MOD, shift
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.resize({ x = resizeStep, y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.resize({ x = -resizeStep, y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.resize({ x = 0, y = resizeStep, relative = true }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.resize({ x = 0, y = -resizeStep, relative = true }))

-- # Screenshot region with mainMod + PrintScr
hl.bind(mainMod .. " + Print",
    hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy && notify-send \"Screenshot copied to clipboard\" -a \"ss\""))

-- # Screenshot current monitor with mainMod + SHIFT + PrintScr
hl.bind(mainMod .. " + SHIFT + Print",
    hl.dsp.exec_cmd(
        "grim -o \"$(hyprctl -j monitors | jq -r '.[] | select(.focused) | .name')\" - | wl-copy && notify-send \"Screenshot of current monitor copied\" -a \"ss\""))

hl.bind(mainMod .. " + CTRL + ALT + L", hl.dsp.exec_cmd("loginctl lock-session"))

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
