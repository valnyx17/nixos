{ pkgs, config, inputs, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  xdg.configFile.nvim.source = mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/neovim/nvim";

  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly.packages.${pkgs.system}.default;
    extraPackages = with pkgs; [
      lua-language-server
      nil
      nixpkgs-fmt
      stylua
      selene
    ];

    # set env variables for neovim to find tiktoken core module
    extraLuaPackages = ps: with ps; [ tiktoken_core ];
  };
}
