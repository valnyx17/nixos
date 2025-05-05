{config, ...}: {
  hardware.nvidia-container-toolkit.enable = builtins.any (driver: driver == "nvidia") config.services.xserver.videoDrivers;
  virtualisation.vmware.host.enable = false;
  virtualisation.docker.enable = true;
}
