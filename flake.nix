{
  description = "NixOS and nix-darwin configs for my machines";
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixOS profiles to optimize settings for different hardware
    hardware.url = "github:nixos/nixos-hardware";

    # Global catppuccin theme
    catppuccin.url = "github:catppuccin/nix";

    # Noctalia Shell
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix Darwin (for MacOS machines)
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    emacs-overlay.url = "github:nix-community/emacs-overlay";

  };

  outputs =
    {
      self,
      catppuccin,
      darwin,
      home-manager,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      # Define user configurations
      users = {
        "Aaron.hc" = {
          inherit (users.hc)
            avatar
            email
            fullName
            gitKey
            ;
          name = "hc";
        };
        hc = {
          avatar = ./files/avatar;
          wallpaper = ./files/wallpaper.jpg;
          email = "1216713811@qq.com";
          fullName = "Chang He Aaron";
          #gitKey = "C5810093";
          name = "hc";
        };
      };

      # Function for NixOS system configuration
      mkNixosConfiguration =
        hostname: username:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs hostname;
            userConfig = users.${username};
            nixosModules = "${self}/modules/nixos";
          };
          modules = [ ./hosts/${hostname} ];
        };

      # Function for nix-darwin system configuration
      mkDarwinConfiguration =
        hostname: username:
        darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {
            inherit inputs outputs hostname;
            userConfig = users.${username};
            darwinModules = "${self}/modules/darwin";
          };
          modules = [ ./hosts/${hostname} ];
        };

      # Function for Home Manager configuration
      mkHomeConfiguration =
        system: username: hostname:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          extraSpecialArgs = {
            inherit inputs outputs;
            userConfig = users.${username};
            nhModules = "${self}/modules/home-manager";
          };
          modules = [
            ./home/${username}/${hostname}
            catppuccin.homeModules.catppuccin
          ];
        };
    in
    {
      nixosConfigurations = {
        energy = mkNixosConfiguration "energy" "hc";
      };

      darwinConfigurations = {
        "AaronMac" = mkDarwinConfiguration "AaronMac" "Aaron.hc";
      };

      homeConfigurations = {
        "Aaron.hc@AaronMac" =
          mkHomeConfiguration "aarch64-darwin" "Aaron.hc"
            "AaronMac";
        "hc@energy" = mkHomeConfiguration "x86_64-linux" "hc" "energy";
      };

      overlays = import ./overlays { inherit inputs; };
    };
}
