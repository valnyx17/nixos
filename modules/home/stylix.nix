{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.niri.homeModules.stylix
  ];
  stylix.targets.niri.enable = true;
  stylix.image = ./wallhaven-expk3o.png;
  stylix.polarity = "dark";
  stylix.base16Scheme = builtins.readFile (pkgs.fetchFromGitHub {
      owner = "camellia-theme";
      repo = "camellia";
      rev = "3b319bb337caccc311e60c3a8d357c4431b63680";
      hash = "sha256-HNdGHJ8n81HpVK9gFiRLZBBh0sz4FIUUx/ykGyoxv0c=";
    }
    + "/ports/base16/camelliaHopeDark.yml");
  stylix.autoEnable = true;
}
