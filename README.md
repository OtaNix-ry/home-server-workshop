# OtaNix workshop: Setting Up a Home Server Using NixOS

## OtaNix-Server

Progression of the configurations (next inherits previous):

- [`initial`](./otanix-server/initial/default.nix): the resulting system after provisioning the disks with [disko.nix](./otanix-server/initial/disko.nix)
- [`secrets`](./otanix-server/secrets/default.nix): adds sops-nix to manage secrets
- [`wireguard`](./otanix-server/wireguard/default.nix): using sops-nix to provide the private key, this system sets up a WireGuard VPN
- [`nginx`](./otanix-server/nginx/default.nix): sets up nginx + self-signed TLS for serving web-based services
- [`vaultwarden`](./otanix-server/vaultwarden/default.nix): runs vaultwarden behind nginx that's configured to be a TLS-terminating reverse-proxy

## Creating the VM

See the [slides](https://github.com/OtaNix-ry/otanix-server-2025-09-08/releases).

## Setting up a libvirt VM

Download [`disko.nix`](./initial/disko.nix)

## Deployment

1. build using `nix-build -A nixosConfigurations.otanix-server-wireguard.config.system.build.toplevel` (this creates the symlink `./result`)
1. copy the system using `nix copy --to ssh://root@192.168.122.248 ./result`
1. deploy with `ssh root@192.168.122.248 $(readlink result)/bin/switch-to-configuration switch`

> Also, try [deploy-bs](https://github.com/xhalo32/deploy-bs) (available in `nix-shell`) which does the above steps automatically:
>
> ```sh
> deploy nixosConfigurations.otanix-server-wireguard root@192.168.122.248
> ```

## Useful links

- [Search for NixOS options](https://search.nixos.org/options?)
- [sops-nix GitHub](https://github.com/Mic92/sops-nix)

## Troubleshooting

### No bootable devices when starting VM

If you want to boot into the live installer, make sure you have a source path configured (pointing to the installer ISO image) for the CDROM device:

![](images/libvirt-cdrom.png)

Also make sure to enable the CDROM as a boot option:

![](images/libvirt-boot-options.png)

After applying and force resetting, you should boot into the installer.

### Unable to start VM

If you get the following error when starting a VM (usually happens after a reboot)

```
Error starting domain: Requested operation is not valid: network 'default' is not active
```

you need to start the default network with

```
virsh -c qemu:///system net-start default
```

> To set the default network to start at boot, run
> ```
> virsh -c qemu:///system net-autostart default
> ```

### SSH key verification failed

The installer generates a new [SSH host key](https://www.ssh.com/academy/ssh/host-key) at boot, so you will likely encounter the following error when trying to SSH in to it after a reboot:

```
$ ssh nixos@192.168.122.215
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
```

This is easily fixed by removing the host from "known hosts":

```
ssh-keygen -R 192.168.122.215
```