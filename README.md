# Nix meetup presentation 2025-09-08

## OtaNix-Server

Progression of the configurations (next inherits previous):

- [`initial`](./otanix-server/initial/default.nix): the resulting system after provisioning the disks with [disko.nix](./otanix-server/initial/disko.nix)
- [`secrets`](./otanix-server/secrets/default.nix): adds sops-nix to manage secrets
- [`wireguard`](./otanix-server/wireguard/default.nix): using sops-nix to provide the private key, this system sets up a WireGuard VPN
- [`nginx`](./otanix-server/nginx/default.nix): sets up nginx + self-signed TLS for serving web-based services
- [`vaultwarden`](./otanix-server/vaultwarden/default.nix): runs vaultwarden behind nginx that's configured to be a TLS-terminating reverse-proxy

## Creating the VM

See the [slides](TODO).

## Deployment

1. build using `nix-build -A nixosConfigurations.otanix-server-wireguard.config.system.build.toplevel` (this creates the symlink `./result`)
1. copy the system using `nix copy --to ssh://root@192.168.122.248 ./result`
1. deploy with `ssh root@192.168.122.248 $(readlink result)/bin/switch-to-configuration switch`

> Also, try [deploy-bs](https://github.com/xhalo32/deploy-bs) (available in `nix-shell`) which does the above steps automatically:
>
> ```sh
> deploy nixosConfigurations.otanix-server-wireguard root@192.168.122.248
> ```
