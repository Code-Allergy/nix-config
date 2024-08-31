import os
import subprocess
from libqtile import bar, layout, hook, qtile
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from qtile_extras import widget
from qtile_extras.widget.decorations import RectDecoration
from screens import screens
from keys import keys
from colors import colors


mod="mod4" # super key
terminal="wezterm"

'''
@hook.subscribe.client_killed
def fallback(window):
    if window.group.windows != {window}:
        return

    for group in qtile.groups:
        if group.windows:
            qtile.current_screen.toggle_group(group)
            return
    qtile.current_screen.toggle_group(qtile.groups[0])
'''


@hook.subscribe.client_new
def disable_floating(window):
    rules = [
        Match(wm_class="mpv")
    ]

    if any(window.match(rule) for rule in rules):
        window.togroup(qtile.current_group.name)
        window.cmd_disable_floating()


groups = [
    Group("WWW", layout='monadtall'),
    Group("DEV", layout='monadtall'),
    Group("MDA", layout='monadtall'),
    Group("WRI", layout='monadtall'),
    Group("TWR", layout='monadtall'),
    Group("SYS", layout='monadtall'),
    Group("EML", layout='monadtall', matches=[Match(wm_class=["evolution"])]),
    Group("DOC"),
    Group("GPU", layout='floating'),
    Group("0", layout='verticaltile'),
    Group("-"),
    Group("="),


]

for i in range(9):
    keys.extend([
        Key([mod], str(i),
            lazy.group[groups[i-1].name].toscreen(),
            desc="Switch to group {}".format(str(i))),
        Key([mod], "Right",
            lazy.screen.next_group(),
            desc="Switch to next group"),
        Key([mod], "Left",
            lazy.screen.prev_group(),
            desc="Switch to previous group"),
        Key([mod, "shift"], str(i),
            lazy.window.togroup(groups[i-1].name, switch_group=True),
            desc=f"Switch to & move focused window to group {str(i)}"),
        Key([mod, "control"], str(i),
            lazy.window.togroup(groups[i-1].name, switch_group=False),
            desc=f"Switch to & move focused window to group {str(i)}"),
    ])

for i in "0-=":
    if i == '-':
        key = "minus"
    elif i == '=':
        key = "equal"
    else:
        key = i

    keys.extend([
        Key([mod], key,
            lazy.group[i].toscreen(),
            desc="Switch to group {}".format(str(i))),
        Key([mod], "Right",
            lazy.screen.next_group(),
            desc="Switch to next group"),
        Key([mod], "Left",
            lazy.screen.prev_group(),
            desc="Switch to previous group"),
        Key([mod, "shift"], key,
            lazy.window.togroup(i, switch_group=True),
            desc=f"Switch to & move focused window to group {str(i)}"),
        Key([mod, "control"], key,
            lazy.window.togroup(i, switch_group=False),
            desc=f"move focused window to group {str(i)}"),
    ])


layout_theme = {"border_width": 3,
                "margin": 4,
                "border_focus": colors[4],
                "border_normal": colors[1]
                }

layouts = [
    layout.MonadTall(**layout_theme),
    layout.Columns(**layout_theme),
    layout.Max(**layout_theme),
    layout.Stack(num_stacks=2, **layout_theme),
    layout.Floating(**layout_theme),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    layout.VerticalTile(**layout_theme),
    # layout.Zoomy(),
]


dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False

floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(wm_class="qimgv"), # viewnior viewer
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        Match(title="Welcome"),
        Match(title="Friends List"), # Steam friend's list
        Match(wm_class="easyeffects"), # easy effects audio gui
        Match(wm_class="kdeconnect-app"), # kde-connect dialog
        Match(wm_class=".blueman-manager-wrapped"),
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
wmname = "LG3D"

@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~/.config/qtile/autostart.sh')
    subprocess.Popen([home])
