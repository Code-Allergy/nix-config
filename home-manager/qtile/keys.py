import os
from libqtile.config import Click, Drag, KeyChord, Key 
from libqtile.command import lazy
from libqtile.lazy import lazy
from libqtile import layout, bar, widget, hook

mod = "mod4"
terminal = "wezterm"
userScripts = "/home/ryan/bin/"


def window_to_previous_screen(qtile, switch_group=False, switch_screen=False):
    i = qtile.screens.index(qtile.current_screen)
    if i != 0:
        group = qtile.screens[i - 1].group.name
        qtile.current_window.togroup(group, switch_group=switch_group)
        if switch_screen == True:
            qtile.cmd_to_screen(i - 1)

def window_to_next_screen(qtile, switch_group=False, switch_screen=False):
    i = qtile.screens.index(qtile.current_screen)
    if i + 1 != len(qtile.screens):
        group = qtile.screens[i + 1].group.name
        qtile.current_window.togroup(group, switch_group=switch_group)
        if switch_screen == True:
            qtile.cmd_to_screen(i + 1)

keys = [
    ##################################################################################################
    #   ESSENTIALS
    ##################################################################################################
    
    Key([mod], "Return", lazy.spawn(terminal)),                         # Launch terminal
    Key([mod, "shift"], "r", lazy.spawn('rofi -show run')),             # Spawn rofi run
    Key([mod], "r", lazy.spawn('rofi -show drun')),                       # Launch rofi - dmenu
    Key([mod, "mod1"], "Escape", lazy.spawn(userScripts + 'rofi-powermenu')),         # Spawn power menu
    Key([], "Print", lazy.spawn(userScripts + "rofi-screenshot")),                    # Spawn screenshot menu

    Key([mod, "control"], "r", lazy.reload_config()),                   # Reload the config
    Key([mod, "control", "shift"], "r", lazy.restart()),                # Force restart QTile
    Key([mod, "control"], "q", lazy.shutdown()),                        # Shutdown Qtile
    Key([mod], "w", lazy.window.kill()),                                # Kill focused window

    Key([mod, "shift"], "l", lazy.spawn('slock')),  # Lock Session
    #Key([mod, "shift"], "s", lazy.widget["widgetbox"].toggle()),       # open/close widget box

    ##################################################################################################
    #   WINDOW MANAGEMENT
    ##################################################################################################
    
    Key([mod], "h", lazy.layout.left()),                                # Move focus to left
    Key([mod], "l", lazy.layout.right()),                               # Move focus to right
    Key([mod], "j", lazy.layout.down()),                                # Move focus down
    Key([mod], "k", lazy.layout.up()),                                  # Move focus up
    Key([mod], "space", lazy.layout.next()),                            # Move window focus to other window

    # Switch between monitors
    Key([mod,"shift"],  "comma",  
        lazy.function(window_to_next_screen)),                          # Move window to left screen
    Key([mod,"shift"],  "period", 
        lazy.function(window_to_previous_screen)),                      # Move window to right screen
    Key([mod,"control"],"comma",  
        lazy.function(window_to_next_screen, switch_screen=True)),      # Move window to left + move screen
    Key([mod,"control"],"period", 
        lazy.function(window_to_previous_screen, switch_screen=True)),  # Move window to right + move screen
    Key([mod,"control"],"slash", lazy.next_screen()),                   # Switch to next screen to the right.

    # Move windows around
    Key([mod, "shift"], "h", lazy.layout.shuffle_left()),               # Move window to the left
    Key([mod, "shift"], "l", lazy.layout.shuffle_right()),              # Move window to the right
    Key([mod, "shift"], "j", lazy.layout.shuffle_down()),               # Move window down
    Key([mod, "shift"], "k", lazy.layout.shuffle_up()),                 # Move window up 

    # Window sizing
    Key([mod], "i", lazy.layout.grow()),                                # Grow window to the left
    Key([mod], "m", lazy.layout.shrink()),                              # Grow window to the right
    Key([mod], "o", lazy.layout.maximize()),                            # Grow window down
    Key([mod], "n", lazy.layout.normalize()),                           # Reset all window sizes
    Key([mod, "shift"], "space", lazy.layout.flip()),                   # Flip the position of the two panes
    
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout()),                              # Toggle between layouts

    ##################################################################################################
    #   PHYSICAL KEYS
    ##################################################################################################
    
    # Standard Media Keys
    Key([], "XF86AudioLowerVolume", lazy.spawn("pamixer -d 5")),        # Lower Volume by 5%
    Key([], "XF86AudioRaiseVolume", lazy.spawn("pamixer -i 5")),        # Raise Volume by 5%
    Key([], "XF86AudioMute", lazy.spawn("pamixer -t")),                 # Mute/Unmute Volume
    #Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause")),       # Play/Pause player

    ##################################################################################################
    #   EXTRAS
    ##################################################################################################
    
    Key([mod, "control"], "p", lazy.spawn("bwmenu")),                   # Bitwarden menu
    Key([mod], "home", lazy.spawn("toggle_notifications")),             # Toggle notification center
    Key([mod, "mod1"], "home", lazy.spawn("clear_notifications")),      # Clears all notifications in menu

    # Launching common apps with mod+ctrl and space
    KeyChord([mod, "control"], "space", [
        # Key([], "q", lazy.spawn("qutebrowser")),                        # Launches Qutebrowser
        Key([], "f", lazy.spawn("firefox")),                            # Launches Firefox
        Key([], "t", lazy.spawn("thunar")),                             # Launches Thunar
        Key([], "c", lazy.spawn("vscodium")),                           # Launches Vim
        Key([], "d", lazy.spawn("discord")),                            # Launches Discord
        Key([], "s", lazy.spawn("steam")),                              # Launches Steam
        # Key([], "o", lazy.spawn("obsidian")),                           # Launches Obsidian
        Key([], "v", lazy.spawn("nvim")),                               # Launches Neovim
    ], False, "Applications"),
    
    ]


mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

# computer specific keys
if os.uname()[1] == 'bigblubbus':
    keys.extend([])

if os.uname()[1] == 'blubbus':
    keys.extend([
        # Brightness keys
    Key([], "XF86MonBrightnessUp",                                      # Increase brightness 5%
            lazy.spawn("light -A 5")),
    Key([], "XF86MonBrightnessDown",                                    # Decrease brightness 5%
            lazy.spawn("light -U 5")),
    ])




