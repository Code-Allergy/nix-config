{
  config,
  pkgs,
  outputs,
  hostname,
  ...
}: let
  # TODO
  hypridle_config = {
    general = {
      lock_cmd = "pidof hyprlock || hyprlock"; # dbus/sysd lock command (loginctl lock-session)
      before_sleep_cmd = "loginctl lock-session";
      after_sleep_cmd = "hyprctl dispatch dpms on";
      ignore_dbus_inhibit = false; # whether to ignore dbus-sent idle-inhibit requests (used by e.g. firefox or steam)
      ignore_systemd_inhibit = false; # whether to ignore systemd-inhibit --what=idle inhibitors
    };

    listener = [
      {
        timeout = 300; # in seconds
        on-timeout = "loginctl lock-session"; # command to run when timeout has passed
      }

      {
        timeout = 330; # 5.5min
        on-timeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
        on-resume = "hyprctl dispatch dpms on"; # screen on when activity is detected after timeout has fired.
      }

      {
        timeout = 1000; # in seconds
        on-timeout = "systemctl hibernate"; # command to run when timeout has passed
      }
    ];
  };
  # else
  # {};

  hyprConfig = outputs.paths.hyprConfig;
in {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      source = [
        "/home/ryan/nix-config/home/ryan/hypr/hyprland.conf"
      ];
      exec-once = "/home/ryan/nix-config/home/ryan/hypr/autostart.sh";
    };

    extraConfig = ''
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

      # Resize with vim motions + MOD, shift
      bind = $mainMod SHIFT, L, resizeactive, $RESIZE_STEP 0
      bind = $mainMod SHIFT, H, resizeactive, -$RESIZE_STEP 0
      bind = $mainMod SHIFT, J, resizeactive, 0 $RESIZE_STEP

      bind = $mainMod SHIFT, K, resizeactive, 0 -$RESIZE_STEP

      # Screenshot region with mainMod + PrintScr
      bind = $mainMod, Print, exec, grim -g "$(slurp)" - | wl-copy && notify-send "Screenshot copied to clipboard" -a "ss"

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

  services.hypridle = {
    enable = true;
    settings = hypridle_config;
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      source = "/home/ryan/nix-config/home/ryan/hypr/themes/mocha.conf";
    };
    extraConfig = ''
      $accent = $mauve
      $accentAlpha = $mauveAlpha
      $font = Montserrat

      # GENERAL
      general {
        disable_loading_bar = true
        hide_cursor = true
      }

      # BACKGROUND
      background {
        monitor =
        path = $HOME/nix-config/wallpapers/lockscreen.png
        blur_passes = 0
        color = $base
      }

      # LAYOUT
      label {
        monitor =
        text = Layout: $LAYOUT
        color = $text
        font_size = 25
        font_family = $font
        position = 30, -30
        halign = left
        valign = top
      }

      # TIME
      label {
        monitor =
        text = $TIME
        color = $text
        font_size = 90
        font_family = $font
        position = -30, 0
        halign = right
        valign = top
      }

      # DATE
      label {
        monitor =
        text = cmd[update:43200000] date +"%A, %d %B %Y"
        color = $text
        font_size = 25
        font_family = $font
        position = -30, -150
        halign = right
        valign = top
      }

      # USER AVATAR
      image {
        monitor =
        path = $HOME/.face
        size = 100
        border_color = $accent
        position = 0, 75
        halign = center
        valign = center
      }

      # INPUT FIELD
      input-field {
        monitor =
        size = 300, 60
        outline_thickness = 4
        dots_size = 0.2
        dots_spacing = 0.2
        dots_center = true
        outer_color = $accent
        inner_color = $surface0
        font_color = $text
        fade_on_empty = false
        placeholder_text = <span foreground="##$textAlpha"><i>󰌾 Logged in as </i><span foreground="##$accentAlpha">$USER</span></span>
        hide_input = false
        check_color = $accent
        fail_color = $red
        fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>
        capslock_color = $yellow
        position = 0, -47
        halign = center
        valign = center
        position = 0 -300
      }
    '';
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = ["/home/ryan/nix-config/wallpapers/mandelbrot_full_blue.png"];
      wallpaper = [",/home/ryan/nix-config/wallpapers/mandelbrot_full_blue.png"];
      splash = true;
    };
  };
}
