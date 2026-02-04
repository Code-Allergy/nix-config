#!/usr/bin/env bash

hyprctl keyword monitor HEADLESS-2,${SUNSHINE_CLIENT_WIDTH}x${SUNSHINE_CLIENT_HEIGHT}@${SUNSHINE_CLIENT_FPS},auto,1,cm,hdr 
hyprctl keyword monitor DP-1,disable
hyprctl keyword monitor HDMI-A-1,disable
