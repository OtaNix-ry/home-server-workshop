#import "@preview/touying:0.6.1": *
#import "@preview/grayness:0.3.0": *

#import themes.simple: *

#let image-slide(config: (:), background: auto, background-img: none, foreground: white, body) = touying-slide-wrapper(
  self => {
    self = utils.merge-dicts(
      self,
      config-common(freeze-slide-counter: true),
      config-page(fill: if background == auto {
        self.colors.primary
      } else {
        background
      }),
      config-page(background: background-img),
    )
    set text(fill: foreground, size: 1.5em)
    touying-slide(self: self, config: config, align(center + horizon, body))
  },
)

#let palette = (
  rgb("#7287fd"), // lavender
  rgb("#209fb5"), // sapphire
  rgb("#40a02b"), // green
  rgb("#df8e1d"), // yellow
  rgb("#fe640b"), // peach
  rgb("#e64553"), // maroon
)

#show link: set text(blue, style: "italic")

#let repo = "https://github.com/OtaNix-ry/home-server-workshop/blob/main/"

// #let bg-img = read("images/background.png", encoding: none)

#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-page(
    // background: image-brighten(bg-img, amount: 0, width: 100%),
  ),
)
// Copied from metropolis theme
#let custom-title-slide(
  config: (:),
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(
      // background: image-brighten(bg-img, amount: 0, width: 100%),
    ),
  )
  let info = self.info + args.named()
  show raw: set text(font: "DejaVu Sans Mono", weight: 600)
  let body = {
    set text(fill: self.colors.neutral-darkest)
    set std.align(horizon)
    block(
      width: 100%,
      inset: 2em,
      {
        components.left-and-right(
          {
            text(size: 1.3em, text(weight: "medium", info.title))
            if info.subtitle != none {
              linebreak()
              text(size: 0.9em, info.subtitle)
            }
          },
          text(2em, utils.call-or-display(self, info.logo)),
        )
        set text(size: .8em)
        if info.author != none {
          block(spacing: 1em, info.author)
        }
        if info.date != none {
          block(spacing: 1em, utils.display-info-date(self))
        }
        set text(size: .8em)
        if info.institution != none {
          block(spacing: 1em, info.institution)
        }
        if extra != none {
          block(spacing: 1em, extra)
        }
      },
    )
  }
  touying-slide(self: self, body)
})

#let info = (
  title: [Setting Up a Home Server Using NixOS],
  subtitle: [OtaNix workshop, 2025-10-29],
  author: [Niklas Halonen & Luukas Pörtfors],
  date: datetime(year: 2025, month: 9, day: 8),
  institution: [OtaNix ry],
  // logo: image-darken(foralli-grayscale, amount: 0, height: 2em),
)

#custom-title-slide(title: "a", ..info)

// = Setting Up a Home Server Using NixOS

// Luukas Pörtfors & Niklas Halonen

// == Topics

// Reasons why you should start by experimenting with a VM:
// - It's hard to accidentally break things or lose data
// - No need to set up access controls, firewalls, VPNs to get started
// - There's very little friction with trying out new tools and ideas and iteration is fast

// - Setting up a VM
//   - Installing NixOS
// - Provisioning services
//   - SSH
//   - VPN
//   - vaultwarden + nginx + TLS
// - Remote deployment

== Practicalities

#table(
  stroke: 0pt,
  columns: (1fr, 3fr),
  table.header([*Time*], [*Topic*]),
  [16:15 -- 16:45], [Presentation and walkthrough],
  [17:00], [Pizza arrives #place(left + bottom, dx: -1.2em, emoji.pizza)],
  [17:00 -- 19:00], [Doing the workshop independently],
)

\

- There are 3 USB drives with minimal NixOS 25.05 image
  - Return the drives after using them

== Prerequisites to do the workshop yourself

- Computer with GNU/Linux
  - Preferably a large amount of RAM (>8GB) #footnote[Consider closing unnecessary applications if you have only 16GB of RAM]
- Nix installed
- Libvirt (or another hypervisor of your choice)
- It's also recommended to clone this repository for yourself. For that you need to have Git installed

== Workshop Objectives

The aim of this workshop is to be both an introduction and a guide to deploying a NixOS server in a _realistic environment_. We will

- Provision a new NixOS virtual machine with *libvirt*.
- Set up secret management with *sops-nix*.
- Set up a *WireGuard* VPN.
- Deploy *nginx* with self-signed certificates on NixOS.
- Deploy *Vaultwarden* with nginx as a reverse proxy.

The materials in this workshop are open source and available on #link(repo)[GitHub].
You can find the latest PDF from the GitHub releases.

= Setting up a libvirt VM

==

#place(center, image("images/nixos-download.png", height: 90%))


#block(
  fill: white,
  inset: (bottom: 1em),
)[
  #set text(30pt)
  Go to #link("https://nixos.org/download") and download the *minimal ISO image* (1.6GB) for your CPU architecture.]

#pause

#place(top + center, dx: 4%, dy: 86%, box(height: 15%, width: 25%, stroke: 2pt + red))

==

Install and open `Virtual Machine Manager` (libvirt).
Add a connection to `QEMU/KVM` (system session #footnote[Using the user session is not recommended as it makes networking and getting an SSH connection more difficult.], requires membership of `libvirtd` group) under `File > Add connection`.

#place(bottom, dy: 1em, image("images/virt-manager.png"))

#pause

#place(horizon + right, dx: 1%, dy: 21%, image("images/qemu-kvm.png", width: 40%))
#pause

#place(top + left, dx: 0.5%, dy: 48%, box(height: 7%, width: 5%, stroke: 2pt + red))

#place(top + left, dx: 2%, dy: 78%, box(height: 10%, width: 25%, stroke: 2pt + orange))

==

#place(bottom + left, dx: -1em, image("images/new-vm.png"))

#place(bottom + right, dx: 1em, image("images/os.png"))

#pause

#place(bottom + right, dx: 1em, image("images/locate-iso.png"))

#place(bottom + right, dx: -18%, dy: -1%, box(height: 10%, width: 13%, stroke: 2pt + red))

==

#block(width: 50%)[
  - Add RAM, CPU and a 20GB of disk storage.
  - Let's use the default NAT network #footnote[Not available in the user session on my machine.]
    - The network might be in an "inactive" state. It should ask whether to start it when you press *Finish*
]

#place(top + right, image("images/install.png"))

==


#place(horizon + left, image("images/boot.png"))

#pause

#place(right, image("images/tty.png"))

\

#place(bottom + center, text(80pt, emoji.party))

==

#v(-1.6em)

- We have booted into the live (non-persistent) NixOS environment.
// - Before we continue, let's set up an SSH connection to the server.
- To get the IPv4 address of the VM, run `ip addr`.
- It suffices to set a password for the `nixos` user to SSH in.

#place(bottom + center, image("images/passwd.png"))

#place(dx: 3%, dy: 62%, box(height: 4%, width: 20%, stroke: 2pt + red))

==

Note: press `LCTRL + ALT` to detach your keyboard from the guest VM.

#image("images/ssh.png")

#pause

And yes -- I use #link("https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/ComicShannsMono")[ComicShannsMono Nerd Font] in my terminal.

== Disk partitioning with Disko

#place(left + horizon)[
  #image("images/disko.png", height: 60%)
  #link("https://github.com/nix-community/disko")[Image source]

  #link(
    repo + "otanix-server/otanix-server/00-initial/disko.nix",
  )[URL to GitHub disko.nix]
]

#place(right + horizon, text(21pt)[
  ```nix
  partitions = {
    boot = { # Legacy boot partition
      size = "1M";
      type = "EF02"; # for grub MBR
    };
    root = { # Data partition
      size = "100%";
      content = {
        type = "filesystem";
        format = "ext4";
        mountpoint = "/";
      };
    };
  };
  ```
])

#pause

#place(dx: 53%, dy: 6%, box(height: 27%, width: 50%, stroke: 2pt + red))

#pause

#place(dx: 53%, dy: 33.4%, box(height: 50%, width: 50%, stroke: 2pt + orange))

== Disk partitioning with Disko

#text(15pt)[
  ```sh
  [nixos@nixos:~]$ sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount disko.nix
  ```
  ```
  disko version 1.12.0
  this derivation will be built:
    /nix/store/xdd4z6np7i95r9wxx7wfgaprc8n41v25-disko-destroy-format-mount.drv
  building '/nix/store/xdd4z6np7i95r9wxx7wfgaprc8n41v25-disko-destroy-format-mount.drv'...
  WARNING: This will destroy all data on the disks defined in disko.devices, which are:

    - /dev/vda

      (If you want to skip this dialogue, pass --yes-wipe-all-disks)

  Are you sure you want to wipe the devices listed above?
  Type 'yes' to continue, anything else to abort: yes
  ```
  ```sh
  [nixos@nixos:~]$ mount
  ```
  ```
  /dev/vda2 on /mnt type ext4 (rw,relatime)
  ```
]

== Disk partitioning with Disko

#place(center + bottom, image("images/disko-meme.png", height: 93%))

// Anectdote: while making the virtual machine, I had to change the partition layout to include a BIOS boot partition instead of efi system partition and using disko made that very easy.

== NixOS installation

#text(14pt)[
  #grid(columns: (1fr,) * 2, gutter: 1em)[
    === 1. Generate the configuration

    ```sh

    [nixos@nixos:~]$ sudo nixos-generate-config --root /mnt
    ```
    ```
    writing /mnt/etc/nixos/hardware-configuration.nix...
    writing /mnt/etc/nixos/configuration.nix...
    For more hardware-specific settings, see https://github.com/NixOS/nixos-hardware.
    ```
    \

    #pause

    === 2. Check `hardware-configuration.nix`

    ```nix
      fileSystems."/" =
        { device = "/dev/disk/by-uuid/7a2c89f3-91ac-4fe1-b7c8-c1eb162dca37";
          fsType = "ext4";
        };
    ```
  ][

    #pause

    #place(dy: -2em)[
      === 3. Edit `configuration.nix`

      ```nix
        # Use the GRUB 2 boot loader.
        boot.loader.grub.enable = true;
        # We are not running UEFI firmware on the virtual machine.
        boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

        networking.hostName = "otanix-server"; # Define your hostname.
        networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
        time.timeZone = "Europe/Helsinki";
        services.openssh.enable = true;

        users.users.root.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDTEXhQHAnlI2MfD26A9QL1hkLnalR4RI7TAiDL2CuMG"
        ];
      }
      ```
    ]
  ]
]

== NixOS installation

#grid(columns: (1fr,) * 2, gutter: 1em)[
  Finally, let's install NixOS on the disk! #emoji.rocket

  `nixos-install` downloads and copies packages and is the most resource intensive part in the process. At least 2GB of ram is recommended#footnote[If you have problems with memory usage, try #link("https://nixos.wiki/wiki/NixOS_Installation_Guide#Create_swap_file")[creating a temporary SWAP file] to build the system configuration].
][
  #text(18pt)[
    ```sh
    [nixos@nixos:/mnt]$ sudo nixos-install
    ```
    ```
    copying channel...
    building the configuration in /mnt/etc/nixos/configuration.nix...
    ...
    updating GRUB 2 menu...
    installing the GRUB 2 boot loader on /dev/vda...
    Installation finished. No error reported.
    setting root password...
    New password:

    installation finished!
    ```
  ]
]

==

#image("images/otanix-server-tty.png")

// #show raw: it => {
// box(fill: red, it)
// }

```sh
𝝺 ssh-keygen -R 192.168.122.248
𝝺 ssh root@192.168.122.248 -i id_rsa_otanix_server
```
```
Last login: Sun Sep  7 12:04:36 2025

[root@otanix-server:~]#
```

#place(bottom + center, text(70pt, emoji.party))

// == SSH

// - ```nix services.openssh.enable = true;```
// - pubkey declaration for users
// - firewall

= Secret management

#place(bottom + right, link(
  repo + "otanix-server/01-secrets",
)[Source code for this part])

== What about secret management?

- Before moving on to provisioning services, we need a *secret management solution* to load secrets onto the server.

#pause

- The server's *identity* is defined by its SSH host keys:
  - `/etc/ssh/ssh_host_ed25519_key` (private)
  - `/etc/ssh/ssh_host_ed25519_key.pub` (public)

- Our *identity* is a local SSH key-pair
  - `id_rsa_otanix_server` (private)
  - `id_rsa_otanix_server.pub` (public)

== Secret management with sops-nix

#grid(columns: (3fr, 2fr), gutter: 1em)[
  - #link("https://github.com/Mic92/sops-nix")[sops-nix] is a secret management solution for NixOS (and H-M)
  - Declare secret files in `.sops.yaml`
  - Edit secrets with ```sh sops secrets.yaml```
  - `ssh-to-age` can be used to convert public SSH keys to #link("https://github.com/FiloSottile/age")[age].
    - For example, the server's host key
      ```sh
      ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
      ```
][
  #text(18pt)[

    === Sops configuration `.sops.yaml`:

    ```yaml
    creation_rules:
      - path_regex: secrets.yaml
        key_groups:
          - age:
              - age19sdmxlqurhaz...
              - age1fwmktgds7wwr...
    ```
    \


    #place(dx: 30%, dy: -31%, box(height: 5%, width: 70%, stroke: 2pt + red))

    #pause

    #place(dx: 30%, dy: -24%, box(height: 5%, width: 70%, stroke: 2pt + blue))

    #pause

    === Editing secrets with SSH key

    ```sh
    export SOPS_AGE_KEY=$(ssh-to-age -private-key < ../../id_rsa_otanix_server)
    sops secrets.yaml
    ```
  ]
]

= WireGuard VPN

#place(bottom + right, link(
  repo + "otanix-server/02-wireguard",
)[Source code for this part])

==

#grid(columns: (1fr,) * 2, gutter: 1em)[
  - WireGuard is a simple and static VPN tunnel
  - Included in the Linux kernel used in NixOS
  - NetworkManager support
  - Suitable for declarative node-to-node tunnels
  - `wg` is provided by `02-wireguard-tools` from nixpkgs
][
  #text(20pt)[
    ```sh
    [root@otanix-server:~]# nix-shell -p 02-wireguard-tools

    [nix-shell:~]# wg genkey |tee privkey
    ANo3R41zG7ixKvIR1iaD98vsKA3x...

    [nix-shell:~]# wg pubkey < privkey
    6kQxC64zcc8v0rBQZBHRFN5cFR5/...
    ```
  ]
]

== Editing secrets with SSH key

#text(20pt)[
  ```sh
  export SOPS_AGE_KEY=$(ssh-to-age -private-key < ../../id_rsa_otanix_server)
  sops secrets.yaml
  ```
]

#place(bottom + center, dy: 1.5em, image("images/sops-emacs.png"))

== Adding sops-nix to NixOS

Let's add the following options to `configuration.nix`:

#text(20pt)[
  ```nix
  {
    imports = [
      (sources.sops-nix + "/nixosModules/sops")
    ];
    sops.defaultSopsFile = ./secrets.yaml;
    sops.age.sshKeyPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];
    sops.secrets."wg0/privateKey" = { };
  }
  ```
]

== Configuring the WireGuard tunnel

#text(20pt)[
  ```nix
  { networking.02-wireguard.interfaces.wg0 = {
      ips = [ "10.127.0.1/24" ];
      listenPort = 51820;
      privateKeyFile = config.sops.secrets."wg0/privateKey".path;
      peers = [
        { publicKey = "rv0iaea+BIHFUmkDnbM+DFE9aFHSzzcdRoQFArrHEhk=";
          allowedIPs = [ "10.127.0.2/32" ]; }
      ];
    };
    networking.firewall.allowedUDPPorts =
      [ config.networking.02-wireguard.interfaces.wg0.listenPort ];
  }
  ```
]

#pause

#place(dx: 4%, dy: -46%, box(height: 18%, width: 85%, stroke: 2pt + red))

== Build and deploy (remotely from the host)

// I have set up a #link("")[repository] with the configuration.

+ Let's build the configuration manually

  ```sh
  nix-build -A nixosConfigurations.otanix-server-02-wireguard.config.system.build.toplevel
  ```
+ Then, copy it to the VM

  ```sh
  nix copy --to ssh://root@192.168.122.248 ./result
  ```

+ Finally, deploy it, i.e. switch to the new configuration on the VM

  ```sh
  ssh root@192.168.122.248 $(readlink result)/bin/switch-to-configuration switch
  ```

== Build and deploy (remotely from the host)

#text(20pt)[
  ```
  updating GRUB 2 menu...
  stopping the following units: audit.service, ...
  setting up /etc...
  sops-install-secrets: Imported /etc/ssh/ssh_host_ed25519_key as age key with fingerprint
    age1fwmktgds7wwrd2qtxwjwg0gvqv9snpzq0jk4chv4gtra5ut7lcvsqkyprm
  ...
  the following new units were started: run-secrets.d.mount, 02-wireguard-wg0.service, 02-wireguard-wg0.target, ...
  ```
]

#pause

#place(dx: 2%, dy: -22%, box(height: 6%, width: 82%, stroke: 2pt + blue))
#place(dx: -1%, dy: -10%, box(height: 12%, width: 95%, stroke: 2pt + red))


== Checking the results

#grid(columns: (1fr,) * 2, gutter: 1em)[

  // - Sops secrets are now available in `/run/secrets`
  //   - By default, only `root` has read access
  WireGuard client configuration:

  #text(18pt)[
    ```conf
    [Interface]
    PrivateKey = 4B0jMF/ll8A2uf5NP4VBua3O...
    Address = 10.127.0.2/32

    [Peer]
    Endpoint = 192.168.122.248:51820
    PublicKey = 6kQxC64zcc8v0rBQZBHRFN5cF...
    AllowedIPs = 10.127.0.0/24
    ```
  ]

  Import the config on the host:

  #text(20pt)[
    ```sh
    nmcli connection import type 02-wireguard file otanix-vpn.conf
    ```
  ]
][
  #text(18pt)[
    === On the virtual machine

    ```sh
    [nix-shell:~]# cat /run/secrets/wg0/privateKey
    ANo3R41zG7ixKvIR1iaD98vsKA3xFYdpiOjcPJDH43A=
    [nix-shell:~]# wg
    ```
    ```
    interface: wg0
      public key: 6kQxC64zcc8v0rBQZBHRFN5cFR5/wkA3VjYpbqiEQB8=
      private key: (hidden)
      listening port: 51820

    peer: rv0iaea+BIHFUmkDnbM+DFE9aFHSzzcdRoQFArrHEhk=
      allowed ips: 10.127.0.2/32
    ```
  ]
]

== Checking the results

#text(20pt)[
  #grid(columns: (1fr,) * 2, gutter: 1em)[
    === Host machine
    ```sh
    𝝺 ping 10.127.0.1

    PING 10.127.0.1 (10.127.0.1) 56(84) bytes of data.
    64 bytes from 10.127.0.1: icmp_seq=1 ttl=64 time=1.65 ms
    64 bytes from 10.127.0.1: icmp_seq=2 ttl=64 time=1.68 ms
    ```
  ][
    === Virtual machine
    ```sh
    [root@otanix-server:~]# ping 10.127.0.2

    PING 10.127.0.2 (10.127.0.2) 56(84) bytes of data.
    64 bytes from 10.127.0.2: icmp_seq=1 ttl=64 time=0.942 ms
    64 bytes from 10.127.0.2: icmp_seq=2 ttl=64 time=1.32 ms
    ```

  ]
]

#pause

#place(bottom + center, text(80pt, emoji.party))

= Web-based service hosting on NixOS: Nginx

#place(bottom + right, link(
  repo + "otanix-server/03-nginx",
)[Source code for this part])

==

#grid(columns: (1fr,) * 2, gutter: 1em)[

  - Use #link("")[NixOS search] to find services that you might want to host.
  - Let's deploy
    + nginx with self-signed TLS
    + Vaultwarden with nginx as a reverse proxy
][

  #place(center)[
    #image("images/nixos-search-tabs.png", height: 1.5em)
    #v(-1em)
    #image("images/nixos-search-nginx.png")
  ]
]

==

#text(18pt)[
  Fisrt, nginx configuration with a self-signed TLS certificate (for `*.10.127.0.1.nip.io`).

  ```nix
  { sops.secrets."tls/key" = {
      sopsFile = ./nginx-secrets.yaml;
      owner = "nginx"; group = "nginx";
    };
    sops.secrets."tls/cert" = {
      sopsFile = ./nginx-secrets.yaml;
      owner = "nginx"; group = "nginx";
    };

    environment.etc."ssl/private/selfsigned.key".source =
      config.sops.secrets."tls/key".path;
    environment.etc."ssl/certs/selfsigned.pem".source =
      config.sops.secrets."tls/cert".path;
  }
  ```
]

#pause

#place(dx: 2%, dy: -74%, box(height: 43%, width: 75%, stroke: 2pt + red))

#pause

#place(dx: 2%, dy: -26%, box(height: 23%, width: 75%, stroke: 2pt + orange))

#place(bottom)[#text(18pt)[
    For more discussion about self-signed certificates on NixOS, see #link("https://discourse.nixos.org/t/have-nix-auto-generate-a-sslcertificate-for-nginx-virtual-host/38358/")[NixOS discourse].
  ]
]

= Web-based service hosting on NixOS: Vaultwarden

#place(bottom + right, link(
  repo + "otanix-server/04-vaultwarden",
)[Source code for this part])

==

- With all the infrastructure in place (secret management, nginx, TLS certificates), we can deploy almost any web service.

#text(20pt)[
  ```nix
  { services.vaultwarden = {
      enable = true;
      config = {
        DOMAIN = "https://vault.10.127.0.1.nip.io";
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
      };
    }; }
  ```
]

== Web-based service hosting on NixOS: Vaultwarden #footnote[#link(repo + "otanix-server/04-vaultwarden")[Source code for this part]]

#text(20pt)[
  ```nix
  { services.nginx = {
      virtualHosts."vault.10.127.0.1.nip.io" = {
        enableACME = false; # Don't use Let's Encrypt
        forceSSL = true; # Redirect plain HTTP traffic to HTTPS
        sslCertificate = "/etc/ssl/certs/selfsigned.pem";
        sslCertificateKey = "/etc/ssl/private/selfsigned.key";
        locations."/".proxyPass = "http://vaultwarden";
      };
      upstreams.vaultwarden.servers."127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}" =
        { };
    }; }
  ```
]

== Checking the results

Connecting to https://vault.10.127.0.1.nip.io now provides access to vaultwarden (after an invalid TLS certificate warning).

#place(bottom + center, dy: 1em, image("images/vault.png", height: 70%))

#pause

#place(bottom + center, text(80pt, emoji.party))

= Thank you for listening!\ \ Questions?

// == Remote\ Deployment

// #place(horizon + center)[
//   #image("images/meme1.png")
//   #link("https://imgur.com/nixos-meme-ENvpYDp")[Image source]
// ]

// == Introducing `deploy-bs`

// https://github.com/xhalo32/deploy-bs

// #columns(2)[
// #image("images/meme2.png")

// #image("images/deploy-bs-meme.png")
// ]
