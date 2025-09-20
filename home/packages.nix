{ pkgs, pkgs-master, ... }:
{
  home.packages = with pkgs; [
    materialgram
  ];
}