#!/bin/sh

nitrogen --restore &
picom &
deadd-notification-center &
kdeconnect-cli -l &
thunar --daemon &
light-locker &
evolution &

# Network system tray applet
nm-applet &

# Bluetooth system tray applet
blueman-applet &

# redshift for night time
#redshift -l 52.17:-106.61 -m randr &

if [ $HOSTNAME == "bigblubbus" ]
then
    steam -silent &
    discord --start-minimized &
    gwe --hide-window &
    clight &
    #sleep 10; clight-gui --tray &
fi

if [ $HOSTNAME == "blubbus" ]
then
    clight-gui --tray &
fi
