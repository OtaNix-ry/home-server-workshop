{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Inherit from previous configuration
    ../wireguard
  ];

  sops.secrets."tls/key" = {
    sopsFile = ./nginx-secrets.yaml;
  };
  sops.secrets."tls/cert" = {
    sopsFile = ./nginx-secrets.yaml;
  };

  environment.etc."ssl/private/selfsigned.key".source = config.sops.secrets."tls/key".path;
  environment.etc."ssl/certs/selfsigned.pem".source = config.sops.secrets."tls/cert".path;

  services.nginx = {
    # Enable nginx with recommended settings
    enable = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
  };

  networking.firewall.allowedTCPPorts = [
    # Open ports to nginx
    80
    443
  ];
}
