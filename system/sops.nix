{inputs, ...}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops.defaultSopsFile = "${../secrets/secrets.yaml}";
  sops.validateSopsFiles = false;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/persist/var/lib/sops-nix/key.txt";
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  sops.age.generateKey = true;
}
