{ stdenv, fetchurl, dpkg, makeWrapper, alsa-lib, atk, cairo, cups, dbus, expat
, fontconfig, freetype, glib, gtk3, libxkbcommon, mesa, pango, udev
, xorg, ... }:

stdenv.mkDerivation rec {
  pname = "cider-2";
  version = "2.6.1";

  src = fetchurl {
    name = "cider_${version}_amd64.deb";
    url = "https://repo.cider.sh/deb/pool/main/c/cider/cider_${version}_amd64.deb";
    sha256 = "0000000000000000000000000000000000000000000000000000";
  };

  nativeBuildInputs = [ dpkg makeWrapper ];
  
  buildInputs = [
    alsa-lib atk cairo cups dbus expat fontconfig freetype glib gtk3
    libxkbcommon mesa pango udev
    xorg.libX11 xorg.libxcb xorg.libXi xorg.libXrender xorg.libXrandr
    xorg.libXcomposite xorg.libXcursor xorg.libXdamage xorg.libXext
    xorg.libXfixes xorg.libXScrnSaver xorg.libXtst
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -r usr/* $out/
    
    # Wrap the binary with necessary flags
    wrapProgram $out/bin/cider \
      --prefix LD_LIBRARY_PATH : ${stdenv.lib.makeLibraryPath buildInputs} \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"
  '';

  meta = with stdenv.lib; {
    description = "Powerful music player that allows you listen to your favorite tracks with style";
    homepage = "https://cider.sh";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
