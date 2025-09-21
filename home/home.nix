{ curversion, ... }: 
{
  imports = [
    ./packages.nix
    ];
  home = {
    stateVersion = "${curversion}";
    username = "lagavulin";
    homeDirectory = "/home/lagavulin";
    sessionVariables = {
    };
  };
}