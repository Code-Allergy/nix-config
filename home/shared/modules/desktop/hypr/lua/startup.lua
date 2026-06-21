require("lua.utils")

hl.on("hyprland.start", function()
    uwsm_run("steam -silent")
    uwsm_run("vesktop --start-minimized")
    uwsm_run("corectrl --minimize-systray")
end)
