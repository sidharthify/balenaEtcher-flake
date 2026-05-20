# Compatibility shim for nix-shell (non-flake)
# Use `nix develop` if you have flakes enabled.
(import (fetchTarball "https://github.com/edolstra/flake-compat/archive/refs/heads/master.tar.gz") {
  src = ./.;
}).shellNix
