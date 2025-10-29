{
  sources ? import ./npins,
  system ? builtins.currentSystem,
  pkgs ? import sources.nixpkgs {
    inherit system;
    config = { };
    overlays = [
      (prev: final: {
        deploy-bs =
          (import sources.deploy-bs {
            pkgs = final; # Inject pkgs dependency. Comment out if deploy-bs builds start failing
          }).package;
      })
    ];
  },
}:
let
  lib = import (sources.nixpkgs + "/lib");
  nixosSystem =
    args:
    import (sources.nixpkgs + "/nixos/lib/eval-config.nix") (
      {
        inherit lib;
        system = "x86_64-linux";

        specialArgs = { inherit sources; };
        modules = args.modules ++ [
          { nixpkgs.pkgs = pkgs; }
        ];
      }
      // builtins.removeAttrs args [ "modules" ]
    );
  typixLib = import (sources.typix + "/lib") {
    inherit (pkgs) lib newScope;
  };

in
{
  nixosConfigurations.otanix-server-initial = nixosSystem {
    modules = [
      ./otanix-server/initial
    ];
  };

  nixosConfigurations.otanix-server-secrets = nixosSystem {
    modules = [
      ./otanix-server/secrets
    ];
  };

  nixosConfigurations.otanix-server-wireguard = nixosSystem {
    modules = [
      ./otanix-server/wireguard
    ];
  };

  nixosConfigurations.otanix-server-nginx = nixosSystem {
    modules = [
      ./otanix-server/nginx
    ];
  };

  nixosConfigurations.otanix-server-vaultwarden = nixosSystem {
    modules = [
      ./otanix-server/vaultwarden
    ];
  };

  presentation = typixLib.buildTypstProject {
    unstable_typstPackages = [
      {
        name = "touying";
        version = "0.6.1";
        hash = "sha256-bTDc32MU4GPbUbW5p4cRSxsl9ODR6qXinvQGeHu2psU=";
      }
      {
        name = "grayness";
        version = "0.3.0";
        hash = "sha256-c0HrerMTmXrf6Zk43JXVLTsRn8AhloLFsgVclkeg/PU=";
      }
    ];
    src = ./slides;
    typstSource = "presentation.typ";
  };

  shell = pkgs.mkShell {
    buildInputs = with pkgs; [
      sops
      ssh-to-age
      deploy-bs # From nixpkgs overlay
    ];
  };
}
