{
	description = "nixos system configuration";
	
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
		nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-24.05";
		flake-utils.url = "github:numtide/flake-utils";

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

		nix-gaming = {
			url = "github:fufexan/nix-gaming";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = {
		self,
		nixpkgs,
		nixpkgs-unstable,
		home-manager,
		flake-utils,
		...
	} @ inputs: flake-utils.lib.eachDefaultSystem(system: let
		pkgs = nixpkgs.legacyPackages.${system};
		inherit (self) outputs;
	in {
			packages = (import ./pkgs pkgs);

			apps = {
				"disko" = {
					type = "app";
					program = "${self.outputs.packages.${system}.disko}/bin/disko";
				};
			};

			formatter = pkgs.alejandra;

			overlays = import ./overlays {inherit inputs;};

			nixosConfigurations.waves = nixpkgs.lib.nixosSystem {
				specialArgs = {
					inherit inputs outputs flake-utils;
				};
				modules = [
					inputs.disko.nixosModules.default
					(import ./disko.nix {device="/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_with_Heatsink_1TB_S6WSNJ0T900943T";})
					./waves.nix
				];
			};

			homeConfigurations."dv@waves" = home-manager.lib.homeManagerConfiguration {
				pkgs = import nixpkgs { system = system; };

				modules = [
					./modules/home/dv.nix
				];
			};
		});
}
