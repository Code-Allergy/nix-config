{nixConfigRoot}: {
  hyprpaper_config = {
    preload = ["${nixConfigRoot}/wallpapers/mandelbrot_full_blue.png"];
    wallpaper = ["${nixConfigRoot}/wallpapers/mandelbrot_full_blue.png"];
    splash = true;
  };
}
