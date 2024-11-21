{
  description = "nixos system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:gytis-ivaskevicius/flake-utils-plus";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nh = {
      url = "github:viperML/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-inspect.url = "github:bluskript/nix-inspect";

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    st.url = "github:devawaves/st";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    flake-utils,
    nixos-cosmic,
    ...
  } @ inputs: let
    mkApp = flake-utils.lib.mkApp;
    mkFlake = flake-utils.lib.mkFlake;
  in
    mkFlake {
      inherit self inputs nixpkgs home-manager;
      channelsConfig.allowUnfree = true;
      sharedOverlays = [
        self.overlays.additions
        self.overlays.modifications
        self.overlays.unstable-packages
      ];

      # host defaults
      hostDefaults.system = "x86_64-linux";
      hostDefaults.modules = [];
      hostDefaults.extraArgs = {inherit flake-utils;};
      hostDefaults.specialArgs = {
        inherit inputs;
        inherit (self) outputs;
      };

      hosts.waves = {
        system = "x86_64-linux";
        modules = [
          inputs.disko.nixosModules.default
          (import ./disko.nix {device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_with_Heatsink_1TB_S6WSNJ0T900943T";})
          {
            nix.settings = {
              substituters = ["https://cosmic.cachix.org/"];
              trusted-public-keys = ["cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="];
            };
          }
          nixos-cosmic.nixosModules.default
          ./system/waves/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
          ./home/valerie/home.nix
        ];
        output = "nixosConfigurations";
      };

      overlays = import ./overlays {inherit inputs;};
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (self) outputs;
    in {
      packages = import ./pkgs pkgs;

      apps = {
        "disko" = {
          type = "app";
          program = "${outputs.packages.${system}.disko}/bin/disko";
        };
      };

      formatter = pkgs.alejandra;
    });
}
