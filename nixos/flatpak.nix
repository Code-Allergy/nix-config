{pkgs, ...}: {
    services.flatpak = {
        enable = true;
        packages = [
            "com.obsproject.Studio"
            "net.lutris.Lutris"
            "sh.ppy.osu"
            "com.usebottles.bottles"
            "com.github.tchx84.Flatseal"
        ];
    };
}




