{
  config,
  lib,
  pkgs,
  sources,
  ...
}:

{
  imports = [
    # Inherit from 00-initial configuration
    ../00-initial
    # Load the sops-nix module
    (sources.sops-nix + "/modules/sops")
  ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.age.sshKeyPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
  ];
  # Path to YAML value
  sops.secrets."wg0/privateKey" = { };
}
