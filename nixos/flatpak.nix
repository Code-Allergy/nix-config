{ ... }:
{
  services.flatpak = {
    enable = true;
    packages = [
      "com.usebottles.bottles"
      "com.github.tchx84.Flatseal"
    ];
  };
}
