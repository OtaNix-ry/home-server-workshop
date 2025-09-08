{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Inherit from previous configuration
    ../nginx
  ];

  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://vault.10.127.0.1.nip.io";
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
    };
  };

  services.nginx = {
    virtualHosts."vault.10.127.0.1.nip.io" = {
      enableACME = false;
      forceSSL = true;
      sslCertificate = "/etc/ssl/certs/selfsigned.pem";
      sslCertificateKey = "/etc/ssl/private/selfsigned.key";
      locations."/" = {
        proxyPass = "http://vaultwarden";
      };
    };
    upstreams.vaultwarden.servers."127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}" =
      { };
  };
}
