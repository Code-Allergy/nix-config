{
  config,
  pkgs,
  outputs,
  ...
}: let
  hyprConfig = outputs.paths.hyprConfig;
in {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      source = [
        "/home/ryan/nix-config/home/ryan/hypr/hyprland.conf"
      ];
    };

    extraConfig = ''
      ###################
      ### KEYBINDINGS ###
      ###################

      # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
      bind = CTRL ALT, T, exec, $terminal
      bind = $mainMod, R, exec, $MENU
      bind = $mainMod, W, killactive,
      bind = $mainMod SHIFT, F, exit,
      bind = $mainMod, E, exec, $fileManager
      bind = $mainMod, V, togglefloating,

      bind = $mainMod, P, pseudo, # dwindle
      bind = $mainMod, TAB, togglesplit, # dwindle

      # Move focus with mainMod + arrow keys
      bind = $mainMod, H, movefocus, l
      bind = $mainMod, L, movefocus, r
      bind = $mainMod, K, movefocus, u
      bind = $mainMod, J, movefocus, d

      # Switch workspaces with mainMod + [0-9]
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10

      # Example special workspace (scratchpad)
      bind = $mainMod, S, togglespecialworkspace, magic
      bind = $mainMod SHIFT, S, movetoworkspace, special:magic

      # Scroll through existing workspaces with mainMod + scroll
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow

      # Resize with vim motions + shift
      bind = $mainMod SHIFT, L, resizeactive, $RESIZE_STEP 0
      bind = $mainMod SHIFT, H, resizeactive, -$RESIZE_STEP 0
      bind = $mainMod SHIFT, J, resizeactive, 0 $RESIZE_STEP

      bind = $mainMod SHIFT, K, resizeactive, 0 -$RESIZE_STEP

      # Screenshot region with mainMod + PrintScr
      bind = $mainMod, Print, exec, ~/.config/hypr/scripts/screenshot

      # Screenshot current monitor with mainMod + SHIFT + PrintScr
      # TODO

      bind = $mainMod CTRL ALT, L, exec, loginctl lock-session


      bindel = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
      bindel = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-

      bindl = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindl = , XF86AudioPlay, exec, playerctl play-pause
      bindl = , XF86AudioPrev, exec, playerctl previous
      bindl = , XF86AudioNext, exec, playerctl next

      bindel = , XF86MonBrightnessUp, exec, brightnessctl s +3%
      bindel = , XF86MonBrightnessDown, exec, brightnessctl s 3%-


    '';
  };
}