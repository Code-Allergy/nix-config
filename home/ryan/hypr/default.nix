{
  inputs,
  pkgs,
  hostname,
  lib,
  ...
}:
let
  inherit (import ./variables.nix { inherit hostname; }) hyprland_variables;
  inherit (import ./configs/hypridle.nix) hypridle_config;
  inherit (import ./configs/hyprlock.nix) hyprlock_config;
  inherit (import ./configs/hyprpaper.nix) hyprpaper_config;
in
{
  imports = [
    ./waybar.nix
  ];

  # cursors
  home.pointerCursor = {
    name = "catppuccin-mocha-blue-cursors";
    package = pkgs.catppuccin-cursors.mochaBlue;
    size = 30;
  };

  home.packages = with pkgs; [
    hyprcursor
    grim
    slurp
    libnotify
    pavucontrol
    qview
    wl-clipboard
    hyprsunset
    hyprpicker
    hyprls
    swaynotificationcenter
    jq # Added jq
  ];

  xdg.configFile = {
    "menus/applications.menu".text = builtins.readFile ./kde-applications.menu;
    # "xdg-desktop-portal/hyprland-portals.conf".text = ''
    #   [preferred]
    #   default = hyprland;gtk
    #   org.freedesktop.impl.portal.FileChooser = kde
    # '';
    "uwsm/env".text = ''
      export HYPRCURSOR_THEME=catppuccin-mocha-blue-cursors
      export HYPRCURSOR_SIZE=30
      export XCURSOR_THEME=catppuccin-mocha-blue-cursors
      export XCURSOR_SIZE=30

      export ELECTRON_OZONE_PLATFORM_HINT=auto
      export GDK_BACKEND=wayland
      export QT_QPA_PLATFORM=wayland
      export XDG_MENU_PREFIX=plasma-
    '';
  };

  services.hyprpolkitagent = {
    enable = true;
  };

  # fuzzel
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        launch-prefix = "uwsm app --";
      };
    };
  };

  programs.wlogout.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

    settings = {
      # Spread the variables
      "$TEARING" = hyprland_variables.TEARING;
      "$INACTIVE_OPACITY" = hyprland_variables.INACTIVE_OPACITY;
      "$MENU" = hyprland_variables.MENU;
      "$WORKSPACE_SWIPE" = hyprland_variables.WORKSPACE_SWIPE;
      "$SHADOWS_ENABLED" = hyprland_variables.SHADOWS_ENABLED; # Comment cleaned
      source = [
        "/home/ryan/nix-config/home/ryan/hypr/hyprland.conf"
      ];
      cursor = {
        default_monitor = hyprland_variables.DEFAULT_MONITOR; # Corrected to use variable
      };
      misc = {
        force_default_wallpaper = 0;
        vfr = true;
        vrr = 2;
        enable_swallow = true;
        swallow_regex = "^(kitty)$";
        font_family = "Montserrat";
      };
      render = {
        direct_scanout = 2;
      };
      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };
      experimental = {
        xx_color_management_v4 = true;
      };
      exec-once =
        [
          "uwsm app -- hyprsunset"
        ]
        ++ (
          if hostname == "bigblubbus" then
            [
              "uwsm app -- steam -silent"
              "uwsm app -- vesktop --start-minimized"
              "uwsm app -- corectrl --minimize-systray"
            ]
          else
            [
              # No hostname-specific startup apps for this configuration
            ]
        );
    };

    extraConfig = ''
      # TODO ENVIRONMENT VARIABLES
      $RESIZE_STEP = 30

      # Unsure if needed but shrug

      #env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
      #env = XDG_CURRENT_DESKTOP,Hyprland
      #env = XDG_SESSION_TYPE,wayland
      #env = WLR_RENDERER,vulkan
      #env = QT_AUTO_SCREEN_SCALE_FACTOR,1
      #env = QT_QPA_PLATFORMTHEME,qt5ct
      #env = SDL_VIDEODRIVER,wayland
      #env = _JAVA_AWT_WM_NONREPARENTING,1
      #env = CLUTTER_BACKEND,wayland
      #env = NIXOS_OZONE_WL,1

      bind = CTRL ALT, T, exec, uwsm app -- $terminal
      bind = $mainMod, R, exec, $MENU
      bind = $mainMod, W, killactive,
      bind = $mainMod SHIFT, F, exit,
      bind = $mainMod, E, exec, uwsm app -- $fileManager
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
      bind = $mainMod SHIFT, Print, exec, grim -o "$(hyprctl -j monitors | jq -r '.[] | select(.focused) | .name')" - | wl-copy && notify-send "Screenshot of current monitor copied" -a "ss" # Implemented

      bind = $mainMod CTRL ALT, L, exec, loginctl lock-session

      # Laptop binds
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
      source = lib.mkForce "/home/ryan/nix-config/home/ryan/hypr/themes/mocha.conf";
    };
    extraConfig = hyprlock_config;
  };

  services.hyprpaper = {
    enable = true;
    settings = hyprpaper_config;
  };
}
