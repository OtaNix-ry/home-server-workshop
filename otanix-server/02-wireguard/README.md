# 02: WireGuard VPN

Note: You should run the commands in this section on the host.

First, let's generate a wireguard keypair using the `wg` command.

> You can install the required wireguard tools by opening a shell with `nix-shell -p wireguard-tools` (or `nix shell nixpkgs#wireguard-tools` if you prefer to use flakes).

```
wg genkey |tee privkey
```

Now, in the `secrets.yaml` file that you opened in the previous section, replace the private key by the output of the previous command.

```
wg pubkey < privkey
```

> If you didn't make any changes to the secrets file, a manual re-encryption is necessary to make the secrets decryptable by the server:
> 
> ```
> sops -i -d secrets.yaml
> sops -i -e secrets.yaml
> ```

> You can also generate a new keypair for the client (host machine). If you do, you need to publicKey in `default.nix` and `PrivateKey` in `otanix-vpn.conf`

## Build and deploy

We can now build the [configuration](./default.nix) that is in this directory.
Run the following command from the root of the repository.

```
NIX_SSHOPTS="-i id_rsa_otanix_server" nixos-rebuild switch \
  -A nixosConfigurations.otanix-server-02-wireguard \
  --target-host root@192.168.122.215
```

### Managing the SSH identity

Instead of using `NIX_SSHOPTS="-i id_rsa_otanix_server"` you can add the identity to your SSH agent with

```
ssh-add id_rsa_otanix_server
```

For the rest of the sections, we will assume you have the key in the agent.

## Checking the results

After the deployment is finished, check that wireguard is running on the VM:

```
[root@otanix-server:~]# wg
interface: wg0
  public key: 6kQxC64zcc8v0rBQZBHRFN5cFR5/wkA3VjYpbqiEQB8=
  private key: (hidden)
  listening port: 51820

peer: rv0iaea+BIHFUmkDnbM+DFE9aFHSzzcdRoQFArrHEhk=
  allowed ips: 10.127.0.2/32
```

## Connecting to WireGuard

Replace the `Endpoint` and `PublicKey` in [otanix-vpn.conf](./otanix-vpn.conf) with the server's address and public wireguard key that you generated with `wg pubkey < privkey` respectively.

If you are using network manager, you can import the client configuration with

```
nmcli connection import type wireguard file otanix-vpn.conf
```

> Making changes to `otanix-vpn.conf` after importing requires that you delete the connection and import it again.
>
> ```
> nmcli con delete otanix-vpn
> ```

You should now be able to connect to the server by its wireguard address `10.127.0.1`:

```
ping 10.127.0.1
```

Once you have a working wireguard connection, you can move on to the [next section](../03-nginx/)