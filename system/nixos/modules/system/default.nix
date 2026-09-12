{
  config,
  lib,
  ...
}:
with builtins;
with lib; {
  options.neer.network = {
    rootDomain = mkOption {
      type = types.str;
      default = "duckduck112.duckdns.org";
      description = "Deployment-wide DNS domain used to derive shared service FQDNs.";
    };

    baseDomain = mkOption {
      type = types.str;
      default = config.neer.network.rootDomain;
      description = "Host-specific DNS suffix used to derive this machine's FQDNs.";
    };
  };

  imports = let
    dirs = filterAttrs (n: v: v != null && !(hasPrefix "_" n) && (v == "directory")) (readDir ./.);
    paths = map (x: "${toString ./.}/${x}") (attrNames dirs);
  in
    paths
    ++ [
      ../../../shared/modules/system
    ];
}
