{
  config,
  lib,
  ...
}:

let
  cfg = config.neer.modules.system.oci;
in
{
  options.neer.modules.system.oci.enable =
    lib.mkEnableOption "OCI application containers";

  config = lib.mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;

      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    virtualisation.oci-containers.backend = "podman";
  };
}
