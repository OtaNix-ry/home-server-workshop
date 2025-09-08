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

  shell = pkgs.mkShell {
    buildInputs = with pkgs; [
      sops
      ssh-to-age
      deploy-bs # From nixpkgs overlay
    ];
  };
}
