{ curversion, ... }: 
{
  imports = [
    ./packages.nix
    ];
  home = {
    stateVersion = "${curversion}";
    username = "skilax";
    homeDirectory = "/home/skilax";
    sessionVariables = {
    };
  };
}