{ pkgs
, ...
}:
{
  programs = {
    steam = {
      enable = true;
      package = pkgs.steam;
    };
    gamescope = { 
      enable = true;
    };
  };
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
  };
}