{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Inherit from previous configuration
    ../01-secrets
  ];

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.127.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = config.sops.secrets."wg0/privateKey".path;
    peers = [
      {
        publicKey = "rv0iaea+BIHFUmkDnbM+DFE9aFHSzzcdRoQFArrHEhk=";
        allowedIPs = [ "10.127.0.2/32" ];
      }
    ];
  };

  networking.firewall.allowedUDPPorts = [ config.networking.wireguard.interfaces.wg0.listenPort ];
}
