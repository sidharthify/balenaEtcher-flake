{
  description = "balenaEtcher — Flash OS images to SD cards & USB drives, safely and easily";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        balena-etcher = pkgs.callPackage ./pkgs/balena-etcher { };
      in
      {
        ### packages
        packages = {
          balena-etcher = balena-etcher;
          default       = balena-etcher;
        };

        ### devShell
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nix-update
            nvd
          ];
        };
      }
    ) // {
      ### overlay
      overlays.default = final: prev: {
        balena-etcher = final.callPackage ./pkgs/balena-etcher { };
      };

      ### nixos module
      nixosModules.default = { config, lib, pkgs, ... }: {
        options.programs.balena-etcher.enable =
          lib.mkEnableOption "balenaEtcher";

        config = lib.mkIf config.programs.balena-etcher.enable {
          environment.systemPackages = [
            self.packages.${pkgs.system}.balena-etcher
          ];
          services.udev.extraRules = ''
            SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem", \
              TAG+="uaccess"
          '';
        };
      };
    };
}
