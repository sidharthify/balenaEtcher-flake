{
  stdenv,
  lib,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  # Electron / GTK runtime deps
  gtk3,
  nss,
  nspr,
  atk,
  at-spi2-atk,
  cups,
  libdrm,
  libxkbcommon,
  mesa,
  pango,
  cairo,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcb,
  dbus,
  alsa-lib,
  expat,
  systemd,
  glib,
  gdk-pixbuf,
  libGL,
  zstd,
}:

let
  ### release metadata
  version = "2.1.6";
  sha256  = "sha256-K967Rsn3UKmr8RwYj/aaQFtKT+0RQzPWNMOz/lmmQFc=";
  #         ^ base64( sha256( balena-etcher_${version}_amd64.deb ) )
  #           nix-prefetch-url --type sha256 \
  #             https://github.com/balena-io/etcher/releases/download/v${version}/balena-etcher_${version}_amd64.deb

  desktopItem = makeDesktopItem {
    name            = "balena-etcher";
    desktopName     = "balenaEtcher";
    comment         = "Flash OS images to SD cards & USB drives";
    exec            = "balena-etcher %U";
    icon            = "balena-etcher";
    categories      = [ "Utility" ];
    mimeTypes       = [ "application/x-raw-disk-image" "application/octet-stream" ];
    startupNotify   = true;
    startupWMClass  = "balenaEtcher";
  };
in
stdenv.mkDerivation {
  pname   = "balena-etcher";
  inherit version;

  src = fetchurl {
    url    = "https://github.com/balena-io/etcher/releases/download/v${version}/balena-etcher_${version}_amd64.deb";
    hash   = sha256;
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
    zstd
  ];

  ### runtime libraries
  buildInputs = [
    gtk3
    nss
    nspr
    atk
    at-spi2-atk
    cups
    libdrm
    libxkbcommon
    mesa           # libgbm
    pango
    cairo
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    dbus
    alsa-lib
    expat
    glib
    gdk-pixbuf
    libGL
    systemd
  ];

  ### unpack
  # dpkg-deb internally calls tar, which tries to restore the setuid bit on
  # chrome-sandbox and fails inside the Nix sandbox. Extract manually with
  # ar + tar --no-same-permissions to avoid that.
  # The upstream .deb uses zstd compression (data.tar.zst).
  unpackPhase = ''
    runHook preUnpack
    ar p "$src" data.tar.zst | tar x --zstd --no-same-permissions
    runHook postUnpack
  '';

  ### install
  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/balena-etcher"
    cp -r usr/lib/balena-etcher/. "$out/lib/balena-etcher/"

    cp -r usr/share "$out/share"

    mkdir -p "$out/bin"
    makeWrapper "$out/lib/balena-etcher/balena-etcher" "$out/bin/balena-etcher" \
      --set ELECTRON_IS_DEV 0 \
      --add-flags "--no-sandbox"

    # Icons
    for size in 16 24 32 48 64 128 256 512; do
      iconDir="$out/share/icons/hicolor/''${size}x''${size}/apps"
      mkdir -p "$iconDir"
      if [ -f "usr/share/icons/hicolor/''${size}x''${size}/apps/balena-etcher.png" ]; then
        cp "usr/share/icons/hicolor/''${size}x''${size}/apps/balena-etcher.png" \
           "$iconDir/balena-etcher.png"
      fi
    done

    runHook postInstall
  '';

  ### metadata
  desktopItems = [ desktopItem ];

  meta = with lib; {
    description      = "Flash OS images to SD cards & USB drives, safely and easily";
    homepage         = "https://etcher.io";
    changelog        = "https://github.com/balena-io/etcher/releases/tag/v${version}";
    license          = licenses.gpl3Only;
    maintainers      = [ ];
    platforms        = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
