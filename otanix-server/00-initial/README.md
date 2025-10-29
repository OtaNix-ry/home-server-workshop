## Setting up a libvirt VM

Here are written instructions for installing NixOS on the VM.
See the [slides](https://github.com/OtaNix-ry/otanix-server-2025-09-08/releases) for creating the VM with libvirt.

You should have a working SSH connection to the VM.

> If you have trouble starting the VM or connecting to it with SSH, see the [general troubleshooting in README](../../README.md#troubleshooting)


Write the contents of [`disko.nix`](./otanix-server/00-initial/disko.nix) to a file `disko.nix` using `nano` for instance.
Then run

```
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount disko.nix
```

Generate the configuration

```
sudo nixos-generate-config --root /mnt
```
