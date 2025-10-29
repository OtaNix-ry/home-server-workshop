# 01: Secret management

This section assumes you have completed [initial provisioning](../00-initial/) already and have a NixOS home server installed and ready.

By default, all shell commands should be executed on the VM (through SSH).
Only a few are executed on the host.

## Secret management with sops-nix

First, we need to convert the server's SSH public host key to _age_.
This is done with the `ssh-to-age` tool which can be "installed" to a nix shell:

```
nix-shell -p ssh-to-age

ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
```

Next, open [.sops.yaml](../.sops.yaml) and replace the age key at `otanix-server: &otanix-server-age age1vsn9we8cz76hctyf2w9mm6zt83gnmyevuewn76zzdxf2k9lc046qg6ycj4` with your server's age key.

## Editing secrets with SSH key

Now we can edit [secrets.yaml](./secrets.yaml) by running the following commands on your host from the current directory:

```
export SOPS_AGE_KEY=$(ssh-to-age -private-key < ../../id_rsa_otanix_server)
sops secrets.yaml
```

> You can install sops by opening a shell with `nix-shell -p sops` (or `nix shell nixpkgs#sops` if you prefer to use flakes).

An editor should open with a file which contains

```
wg0:
    privateKey: ANo3R41zG7ixKvIR1iaD98vsKA3xFYdpiOjcPJDH43A=
```

In [next section](../02-wireguard/), we will generate a new wireguard keypair, so keep the editor open for now.
