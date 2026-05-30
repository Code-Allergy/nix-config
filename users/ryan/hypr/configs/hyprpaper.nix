{ self }:
{
  hyprpaper_config = {
    wallpaper = {
      monitor = "";
      path = self + "/wallpapers/mandelbrot_full_blue.png";
      fit_mode = "cover";
    };
  };
}
