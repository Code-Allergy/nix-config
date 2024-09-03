{pkgs, ...}: {
    services.flatpak = {
        enable = true;
        packages = [
            "com.obsproject.Studio"
            "net.lutris.Lutris"
        ];
    };
}




