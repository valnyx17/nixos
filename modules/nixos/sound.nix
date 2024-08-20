{...}: {
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    lowLatency = {
      enable = true;
      # defaults (USES nix-gaming PIPEWIRE LOW LATENCY MODULE!)
      quantum = 64;
      rate = 48000;
    };
  };
}
