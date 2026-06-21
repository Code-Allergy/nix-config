-- TODO --

local mainMod = "SUPER"

hl.bind("CTRL + ALT + T", hl.dsp.exec_cmd("uwsm app -- kitty"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("fuzzel"))
-- # hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("killactive"))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd("exit"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("uwsm app -- $fileManager"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("togglefloating"))

hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())         -- dwindle
hl.bind(mainMod .. " + TAB", hl.dsp.layout("togglesplit")) -- dwindle only

-- Move focus with mainMod + arrow keys
-- bind = mainMod .. " + H", movefocus, l
-- bind = mainMod .. " + L", movefocus, r
-- bind = mainMod .. " + K", movefocus, u
-- bind = mainMod .. " + J", movefocus, d

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

-- # Resize with vim motions + MOD, shift
-- bind = mainMod .. " + SHIFT + L", resizeactive, $RESIZE_STEP 0
-- bind = mainMod .. " + SHIFT + H", resizeactive, -$RESIZE_STEP 0
-- bind = mainMod .. " + SHIFT + J", resizeactive, 0 $RESIZE_STEP
-- bind = mainMod .. " + SHIFT + K", resizeactive, 0 -$RESIZE_STEP

-- # Screenshot region with mainMod + PrintScr
-- bind = mainMod .. " + Print", exec, grim -g "$(slurp)" - | wl-copy && notify-send "Screenshot copied to clipboard" -a "ss"

-- # Screenshot current monitor with mainMod + SHIFT + PrintScr
-- bind = mainMod .. " + SHIFT + Print", exec, grim -o "$(hyprctl -j monitors | jq -r '.[] | select(.focused) | .name')" - | wl-copy && notify-send "Screenshot of current monitor copied" -a "ss" # Implemented

hl.bind(mainMod .. " + CTRL + ALT + L", hl.dsp.exec_cmd("loginctl lock-session"))
