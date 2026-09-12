{lib}: let
  command = args: lib.concatStringsSep " \\\n  " args;
  port = "\${PORT}";
in {
  inherit command port;

  llamaModel = {
    name,
    description,
    file,
    context,
    extraFiles ? [],
    cacheType ? "f16",
    ubatch ? 256,
    batch ? null,
    extraArgs ? [],
  }: {
    inherit name description;
    cacheFiles = [file] ++ extraFiles;
    ttl = 600;
    cmd = command (
      [
        "llama-server"
        "--host 127.0.0.1"
        "--port ${port}"
        "-m /models/${file}"
        "-ngl 999"
        "-fa on"
        "-ctk ${cacheType}"
        "-ctv ${cacheType}"
      ]
      ++ lib.optional (batch != null) "-b ${toString batch}"
      ++ [
        "-ub ${toString ubatch}"
        "-c ${toString context}"
      ]
      ++ extraArgs
      ++ ["-np 1"]
    );
  };
}
