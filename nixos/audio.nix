{ pkgs, config, ... }:

{ # will add pipewire settings later
  environment.systemPackages = with pkgs; [
    pulseaudio
    pamixer
  ];
}