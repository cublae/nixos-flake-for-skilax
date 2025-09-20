{
  description = "nixos-open-base-flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  

  outputs = { 
    self
  , nixpkgs
  , home-manager
  , ... }@inputs:
  
  let
    system = "x86_64-linux"; 
    curversion = "25.11";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
      overlays = [
        (final: prev: {
        })
      ];
    };
  in {
    nixosConfigurations.skilax = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
      inherit inputs system pkgs curversion;
      };
      modules = [
        ./nixos/configuration.nix
        home-manager.nixosModules.home-manager
        { 
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.skilax = import (./. + "/home/home.nix") ;
            extraSpecialArgs = { inherit curversion inputs; };
          };
        }
      ];
    };
  };
}