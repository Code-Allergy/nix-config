-- window rules

hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

local floating_window_classes = {
    "ark",
    "org.freedesktop.impl.portal.desktop.kde",
    "spotube",
    "pavucontrol",
}

for _, class in ipairs(floating_window_classes) do
    hl.window_rule({
        name = "float-" .. class,
        match = { class = class },
        float = true,
    })
end


hl.window_rule({
    name = "opaque-firefox-pip",
    match = { class = "firefox", title = "Picture-in-Picture" },
    opaque = true,
})
