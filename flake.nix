{
  description = "nixos system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-db = {
      url = "github:mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    nh = {
      url = "github:viperML/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mysecrets = {
      url = "git+ssh://git@192.168.1.203:2222/deva/secrets.git?ref=main&shallow=1";
      flake = false;
    };

    stylix.url = "github:danth/stylix";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    apps = forAllSystems (system: {
      "clone" = {
        type = "app";
        program = self.outputs.packages.${system}.clone;
      };
      "disko" = {
        type = "app";
        program = self.outputs.packages.${system}.disko;
      };
    });

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    # nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    # homeManagerModules = import ./modules/home-manager;

    nixosConfigurations.waves = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs;
      };
      modules = [
        inputs.disko.nixosModules.default
        (import ./disko.nix {device = "/dev/nvme1n1";})
        {networking.hostName = "waves";}
        ./os/configuration.nix
        ./waves-hardware.nix
        inputs.impermanence.nixosModules.impermanence
        inputs.stylix.nixosModules.stylix
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
        }
        ./os/users.nix
        ./os/styling.nix
      ];
    };
  };
}
