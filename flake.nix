{
  description = "pengeg's jovian nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";

    desktop-config = {
      url = "github:gegnep/nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, jovian, home-manager, catppuccin, desktop-config, ... }@inputs: {
    nixosConfigurations.nixdeck = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      
      modules = [
        # Jovian MUST come first
        jovian.nixosModules.jovian
        
        ./hardware-configuration.nix
        ./configuration.nix
        
        # Catppuccin theming
        catppuccin.nixosModules.catppuccin
        
        # Home Manager
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; };
            users.deck = import ./home.nix;
          };
        }
      ];
    };
  };
}
