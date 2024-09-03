#!/bin/sh

hyprpaper &
hypridle &
dunst &

systemctl --user start plasma-polkit-agent &

if [ $HOSTNAME = "bigblubbus" ]; then
    vesktop --start-minimized &
    steam -silent &
    corectrl --minimize-systray &
fi

if [ $HOSTNAME = "blubbus" ]; then
    # Shrug
fi

