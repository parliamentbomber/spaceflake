{
  description = "spaceflake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-gaming.url = "github:fufexan/nix-gaming";
    lanzaboote.url = "github:nix-community/lanzaboote";
    blender-bin.url = "github:edolstra/nix-warez?dir=blender";
    nixvim.url = "github:nix-community/nixvim";
    anyrun.url = "github:anyrun-org/anyrun";
    hyprland = {url = "git+https://github.com/hyprwm/hyprland?submodules=1";}; # broken normally
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    watershot = {
      url = "github:kirottu/watershot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    nixosConfigurations = {
      "cherry" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./profiles/cherry.nix
          # inputs.disko.nixosModules.disko
        ];
      };
    };
    nixosConfigurations = {
      "blueberry" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./profiles/blueberry.nix
          inputs.lanzaboote.nixosModules.lanzaboote
        ];
      };
    };


    homeConfigurations = {
      "devin@cherry" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./home/cherry.nix
        ];
      };
      "devin@blueberry" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./home/blueberry.nix
          inputs.nixvim.homeManagerModules.nixvim
          inputs.spicetify-nix.homeManagerModules.default
          inputs.anyrun.homeManagerModules.default
        ];
      };
    };
  };
}
