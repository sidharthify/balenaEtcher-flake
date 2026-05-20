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

## Packaging notes

**`.deb` extraction:** `dpkg-deb` is not used for unpacking because it tries to restore the `setuid` bit on `chrome-sandbox`, which the Nix build sandbox disallows. Instead, the `.deb` is extracted with `ar | tar --zstd --no-same-permissions` to skip permission restoration.

**`etcher-util` sidecar hack:** `etcher-util` is a [`pkg`](https://github.com/yao-pkg/pkg)-built binary: it bundles a full Node.js runtime with a virtual filesystem blob appended after the ELF sections. `autoPatchelfHook` rewrites those ELF sections to fix library paths, but in doing so it shifts the blob and breaks the offset calculation pkg uses to locate it at runtime (shows up as `Pkg: Error reading from file`).

The workaround: the original binary is saved in `preFixup` before `autoPatchelfHook` touches it, then restored in `postFixup` as `etcher-util.real`. A shell wrapper replaces `etcher-util` and invokes the binary via `ld-linux` directly with an explicit `--library-path`, so it finds its shared libraries without needing its ELF headers patched.

## License
GPL3
