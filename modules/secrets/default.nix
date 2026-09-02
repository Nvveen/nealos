{ config, ... }:

{
  sops.defaultSopsFile = ../../secrets/common.yaml;

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets."users/root/password".neededForUsers = true;

  users.users.root.hashedPasswordFile = config.sops.secrets."users/root/password".path;
}
