{
  description = "V's NixOS Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    zen-browser.url = "github:valnyx17/zen-browser-flake";
    flake-utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    impermanence.url = "github:nix-community/impermanence";
    nh = {
      url = "github:viperML/nh";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    flake-utils,
    ...
  } @ inputs: let
    mkApp = flake-utils.lib.mkApp;
    mkFlake = flake-utils.lib.mkFlake;
  in
    mkFlake {
      inherit self inputs nixpkgs home-manager;
      overlays = import ./overlays.nix {inherit inputs;};
      sharedOverlays = [
        self.overlays.additions
        self.overlays.modifications
        self.overlays.unstable-packages
      ];

      hostDefaults.extraArgs = {inherit flake-utils;};
      hostDefaults.specialArgs = {
        inherit inputs;
        inherit (self) outputs;
      };

      hosts.wireframe = {
        system = "x86_64-linux";
        modules = [
          inputs.disko.nixosModules.default
          (import ./hosts/wireframe/disko.nix {device = "/dev/disk/by-id/nvme-Samsung_SSD_979_PRO_with_Heatsink_1TB_S6WSNJ0T900943T";})
          inputs.impermanence.nixosModules.impermanence
          ./hosts/wireframe/configuration.nix
        ];
      };

      homeConfigurations = {
        "v@wireframe" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = [
              self.overlays.additions
              self.overlays.modifications
              self.overlays.unstable-packages
              inputs.emacs-overlay.overlays.default
            ];
            config = {
              allowUnfree = true;
            };
          };
          modules = [./hosts/wireframe/home.nix];
          extraSpecialArgs = {
            inherit inputs;
            inherit (self) outputs;
          };
        };
      };
    };
}
