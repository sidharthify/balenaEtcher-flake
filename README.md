# balenaEtcher Nix Flake

---

## Usage

### One-liner (no install)

```bash
nix run github:sidharthify/balenaEtcher-flake
```

### Add to a NixOS configuration

```nix
# flake.nix
{
  inputs.balena-etcher.url = "github:sidharthify/balenaEtcher-flake";

  outputs = { self, nixpkgs, balena-etcher, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        balena-etcher.nixosModules.default
        { programs.balena-etcher.enable = true; }
      ];
    };
  };
}
```

### Add to Home Manager or environment.systemPackages

```nix
inputs.balena-etcher.url = "github:sidharthify/balenaEtcher-flake";

environment.systemPackages = [
  inputs.balena-etcher.packages.${system}.default
];
```

### Use the overlay

```nix
nixpkgs.overlays = [ inputs.balena-etcher.overlays.default ];
```

---

## Updating

The [Update workflow](.github/workflows/update.yml) runs **every Monday at 09:00 UTC** and automatically commits the new version and hash directly to the branch.

---

## Dev shell

```bash
# with flakes
nix develop

# without flakes (uses shell.nix)
nix-shell
```

Drops you into a shell with `nix-update` and `nvd` available.

---

## Notes

- Only **x86_64-linux** is supported
- The application requires access to block devices; the NixOS module adds the appropriate udev rule

## License
GPL3
