{lib, ...}: {
  systemd.services.sshd.wantedBy = lib.mkForce [];
}
