import os
import subprocess
from colors import colors
from libqtile.config import Screen 
from libqtile import layout, bar, widget, hook, qtile
from libqtile.lazy import lazy
from qtile_extras import widget
from qtile_extras.widget.decorations import PowerLineDecoration

# bigblubbus configurables
big_blubbus_font_size = 12
blubbus_font_size = 15


# font pack
xf="Cantarell"

terminal="xterm"


@hook.subscribe.screens_reconfigured
def send_to_second_screen():
    if len(qtile.screens) > 1:
        qtile.groups_map["DOC"].cmd_toscreen(1, toggle=False)


@hook.subscribe.screen_change
def restart_on_randr(qtile, ev):
	qtile.cmd_restart()


def get_monitor_count(): # returns a list of names of monitors
    output = [l for l in subprocess.check_output(["xrandr"]).decode("utf-8").splitlines()]
    return [l.split()[0] for l in output if " connected " in l]

@hook.subscribe.startup_complete
def start_finished():
    if len(get_monitor_count()) > 1:
        qtile.focus_screen(1)
        qtile.groups_map["0"].cmd_toscreen(toggle=False)
        qtile.focus_screen(0)
        qtile.groups_map["WWW"].cmd_toscreen(toggle=False)

def generate_bigblubbus_widgets():
    xx = big_blubbus_font_size
    powerline = {
        "decorations": [PowerLineDecoration()]
    }

    widgets=[
    widget.CurrentLayoutIcon(
        custom_icon_paths=[os.path.expanduser("~/.config/qtile/icons")],
        scale=0.85,
        padding=4,
        background=colors[0],
        **powerline,
    ),
    
    widget.GroupBox(
        font=xf,
        fontsize=xx,
        margin_y=1,
        margin_x=1,
        padding_y=5,
        padding_x=3,
        borderwidth=3,
        spacing=0,
        inactive=colors[15],
        active=colors[4],
        background=colors[1],
        rounded=True,
        highlight_color=colors[0],
        highlight_method="block",
        
        # when focused on main
        this_current_screen_border=colors[6],
        other_screen_border=colors[9],
        
        # when unfocused on main
        this_screen_border=colors[10],
        other_current_screen_border=colors[7],
        
        # highlight text black
        block_highlight_text_color=colors[0],
        **powerline,
    ),
    widget.WindowName(
        font=xf,
        fontsize=xx,
        foreground=colors[7],
        background=colors[0],
        
        **powerline,
    ),
    
    widget.CheckUpdates(
        font=xf,
        fontsize=xx,
        foreground = colors[1],
        background = colors[0],
        colour_have_updates = colors[7],
        colour_no_updates = colors[0],

        update_interval = 1800,
        distro = "Arch_checkupdates",
        display_format = "Updates: {updates} ",
        mouse_callbacks = {
            'Button1': lambda: qtile.cmd_spawn('kitty -e sudo pacman -Syu')
            },
        padding = 5,
        **powerline,
     ),
     
     widget.StatusNotifier(
        background=colors[0],
        icons_size=20,
        padding=4,
        **powerline,
    ),

    widget.Net(
        font=xf,
        fontsize=xx,
        foreground = colors[0],
        background = colors[12],
        
        interface = "enp7s0",
        format = 'Net: {down} ↓↑ {up}',
        padding = 5,
        **powerline,        
    ),
    
    widget.Memory(
        font=xf,
        fontsize=xx,
        background=colors[11],
        foreground=colors[0],
        
        measure_mem='G',
        format='{MemUsed: .2f} GB',
        **powerline,
    ),

    widget.CPU(
        font=xf,
        fontsize=xx,
        background=colors[8],
        foreground=colors[0],
        
        format='{load_percent}% {freq_current}GHz',
    ),

    widget.ThermalSensor(
        font=xf,
        fontsize=xx,
        background=colors[8],
        foreground=colors[0],
        tag_sensor='it8686-3',
        format='{temp:.1f}{unit}',
        **powerline,
    ),

    widget.NvidiaSensors(
        font=xf,
        fontsize=xx,
        background=colors[6],
        foreground=colors[0],
        format='{perf} {temp}°C',

        **powerline,
    ),

    widget.Volume(
        font=xf,
        fontsize=xx,
        background=colors[4],
        foreground=colors[0],
        mouse_callbacks={},
        update_interval=0.2,
        limit_max_volume=True,
        fmt='SND: {}',
        **powerline,
    ),
    
    widget.Clock(
        font=xf,
        fontsize=xx,
        foreground=colors[0],
        background=colors[2],
        
        mouse_callbacks={
            'Button1': lambda: qtile.cmd_spawn('toggle_notifications'),
            'Button3': lazy.spawn('firefox https://theweathernetwork.com')
        },
        format="%B %d, %H:%M")]
    
    return widgets


def generate_bigblubbus_screens():
    if len(get_monitor_count()) == 1:
        screens = [
            Screen(
                top=bar.Bar(
                generate_bigblubbus_widgets(),
                20,
                background=colors[0],
                foreground=colors[1],
                ),
            )
        ]
    
    elif len(get_monitor_count()) == 2:

        screen2 = generate_bigblubbus_widgets()
        screen2 = screen2[0:3]+[screen2[-1]]
        screen1 = generate_bigblubbus_widgets()
        screens = [
        Screen(
            top=bar.Bar(
                screen1,
                20,
                background=colors[0],
                foreground=colors[1],
                    ),
        ),
        Screen(
            bottom=bar.Bar(
                screen2,
                33,
                background=colors[0],
                foreground=colors[1],
                ),
        )
    ]
    
    return screens


def generate_blubbus_widgets():
    xx = blubbus_font_size
    powerline = {
        "decorations": [PowerLineDecoration()]
    }
    
    widgets=[
    widget.CurrentLayoutIcon(
        background=colors[0],
        custom_icon_paths=[os.path.expanduser("~/.config/qtile/icons")],
        scale=0.55,
        padding=0,
        **powerline,
    ),

    widget.GroupBox(
        font=xf,
        fontsize=xx,
        margin_y=3,
        margin_x=1,
        padding_y=1,
        padding_x=2,
        borderwidth=3,
        spacing=0,
        inactive=colors[15],
        active=colors[4],
        background=colors[1],
        rounded=True,
        highlight_color=colors[0],
        highlight_method="block",
        
        # when focused on main
        this_current_screen_border=colors[6],
        other_screen_border=colors[9],
        
        # when unfocused on main
        this_screen_border=colors[10],
        other_current_screen_border=colors[7],
        
        # highlight text black
        block_highlight_text_color=colors[0],
        **powerline,
    ),

    widget.WindowName(
        font=xf,
        fontsize=13,
        foreground=colors[7],
        background=colors[0],
        **powerline,
        padding=5,
    ),

    widget.CheckUpdates(
        background = colors[0],
        foreground = colors[1],
        colour_have_updates = colors[7],
        colour_no_updates = colors[0],

        update_interval = 1800,
        distro = "Arch_checkupdates",
        display_format = "!{updates} ",
        mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(terminal+' sudo pacman -Syu')},
        padding = 5,
     ),

    widget.Systray(
        background=colors[0],
        icons_size=20,
        padding=4,
        **powerline,
    ),

    widget.Memory(
        font=xf,
        fontsize=xx,
        background=colors[15],
        foreground=colors[0],
        
        measure_mem='G',
        format='{MemUsed: .2f} GB',
        **powerline,
    ),

    widget.CPU(
        font=xf,
        fontsize=xx,
        background=colors[2],
        foreground=colors[0],

        format='{load_percent}%',
        **powerline,
    ),

    widget.PulseVolume(
        font=xf,
        fontsize=xx,
        background=colors[4],
        foreground=colors[0],

        mouse_callbacks={},
        update_interval=0.2,
        limit_max_volume=True,
        fmt='SND: {}',
        **powerline,
    ),

    # widget.Battery(
    #     font=xf,
    #     fontsize=xx,
    #     foreground=colors[0],
    #     background=colors[5],

    #     format="{watt:.2f} W {percent:2.0%}",
    #     notify_below=10,
    #     update_interval=5,
    #     **powerline,
    # ),

    widget.Clock(
        font=xf,
        fontsize=xx,
        foreground=colors[0],
        background=colors[7],

        format="%B %d, %H:%M",
    ),
        ]
    return widgets


def generate_blubbus_screens():
    widgets = generate_blubbus_widgets()
    active_monitors = get_monitor_count()
    screens = [Screen(
        wallpaper = "~/.config/qtile/background.png",
        # wallpaper_mode = "stretch",
        top=bar.Bar(
            widgets,
            30,
            background=colors[0],
            foreground=colors[1],
        )
    )]

    for i in range(len(active_monitors)-1):
        raw_widgets = generate_blubbus_widgets()
        secondary_monitor_widgets = raw_widgets[0:4] + raw_widgets[5:]
        screens.append(Screen(
            top=bar.Bar(
                secondary_monitor_widgets,
                20,
                background=colors[0],
                foreground=colors[1],
            )))
    # eDP-1
    print(screens)
    return screens


if os.uname()[1] == "bigblubbus":
    screens = generate_bigblubbus_screens()
if os.uname()[1] == "blubbus":
    screens = generate_blubbus_screens()


