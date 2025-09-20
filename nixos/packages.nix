{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    brightnessctl
    libva-utils
    vulkan-headers
    vulkan-tools
    vulkan-loader
    pulseaudio
  ];
}