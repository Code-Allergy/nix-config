{ hostname }:

{
  hyprland_variables =
    if hostname == "bigblubbus" then
      {
        TEARING = true;
        INACTIVE_OPACITY = 0.9;
        MENU = "fuzzel";
        WORKSPACE_SWIPE = true;
        DEFAULT_MONITOR = "DP-1";
        SHADOWS_ENABLED = true; # <-- Added
      }
    else
      {
        TEARING = false;
        INACTIVE_OPACITY = 1.0;
        MENU = "fuzzel";
        WORKSPACE_SWIPE = true;
        DEFAULT_MONITOR = "eDP-0";
        SHADOWS_ENABLED = false; # <-- Added
      };
}
