{inputs, ...}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = "${../secrets/secrets.yaml}";

    age = {
      # I'd prefer different OpenSSH keys for different hosts so I'm not 100% screwed if one of my devices get compromised (SSH traffic potentially being decrypted and analyzed).
      # Therefore, we set a custom path for the SSH key.
      sshKeyPaths = ["/persist/var/lib/sops-nix/ssh_host_ed25519_key"];
      keyFile = "/persist/var/lib/sops-nix/key.txt";
      generateKey = false;
    };

    secrets.v-password.neededForUsers = true;
    secrets.tera-password.neededForUsers = true;
    secrets.root-password.neededForUsers = true;

    secrets = {
      reverse_proxy_server_privkey = {};
      reverse_proxy_client_privkey = {};
      caddy_docker_env = {};
      tailscale_docker_env = {};
      forgejo_db_docker_env = {};
      forgejo_server_docker_env = {};
      passbolt_db_docker_env = {};
      passbolt_passbolt_docker_env = {};
      pterodactyl_db_docker_env = {};
      pterodactyl_pterodactyl_docker_env = {};
      immich_db_docker_env = {};
      immich_immich_docker_env = {};
      synapse_db_docker_env = {};
      synapse_synapse_docker_env = {};
      synapse_synapse_signing_docker_env = {};
    };
  };
}
