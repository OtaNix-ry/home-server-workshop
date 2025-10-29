# OtaNix workshop: Setting Up a Home Server Using NixOS

You can find the slides in the [GitHub releases](https://github.com/OtaNix-ry/home-server-workshop/releases/tag/latest).

## OtaNix-Server

Progression of the configurations (next inherits previous):

- [00: Setting up a libvirt VM](./otanix-server/00-initial/)
- [01: Secret management](./otanix-server/01-secrets/)
- [02: Wireguard VPN](./otanix-server/02-wireguard)
- [03: Nginx](./otanix-server/03-nginx/): set up nginx + self-signed TLS for serving web-based services
- [04: Vaultwarden](./otanix-server/04-vaultwarden/): runs vaultwarden (a password manager) behind the nginx that's configured to be a TLS-terminating reverse-proxy

Start by cloning the repository with `git clone https://github.com/OtaNix-ry/home-server-workshop` and open the guide for section [00: Setting up a libvirt VM](./otanix-server/00-initial/).

The markdown material is complementary to the slides, so you should have both open.

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