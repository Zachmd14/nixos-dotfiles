{ pkgs, username, ... }:

let
  factorio-fhs = pkgs.buildFHSEnv {
    name = "factorio";
    targetPkgs = pkgs: with pkgs; [
      xorg.libXrandr
      xorg.libXcursor
      xorg.libXi
      xorg.libXinerama
      libGL
      alsa-lib
    ];
    runScript = "/home/${username}/Games/Factorio_Linux/factorio/bin/x64/factorio";
  };

  tex = pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-medium wrapfig capt-of;
  };
in


{
  environment.systemPackages = with pkgs; [
    ly
    yt-dlp
    anki
    sox
    ffmpeg
    python3
    python3Packages.matplotlib
    steam
    apacheHttpd
    apacheHttpdPackages.php
    virt-manager
    virtio-win
    valgrind
    scrot
    (mixxx.overrideAttrs (old: {
      version = "2.6-beta";
      src = fetchFromGitHub {
        owner = "mixxxdj";
        repo = "mixxx";
        rev = "2.6";
        hash = "sha256-vWNOpswsH8O0PxWLyfj+Vp/SJzCdmxDtnsnAfPQViBU=";
      };
      postPatch = ''
        substituteInPlace CMakeLists.txt \
          --replace-warn "LIBDJINTEROP_VERSION 0.27.1" "LIBDJINTEROP_VERSION ${libdjinterop.version}"
      '';
    }))
    nicotine-plus
    arandr
    darktable
    tldr
    black
    ispell
    libreoffice
    tlp
    zathura
    acpi
    virtiofsd
    html-tidy
    lazygit
    gh
    feh
    tree
    prettier
    imagemagick
    clang-tools
    brightnessctl
    xmodmap
    wineWow64Packages.stable
    pi-coding-agent
    pipewire
    neovim
    syncthing
    cider-2
    nixpkgs-fmt
    alsa-utils
    vesktop
    opencode
    flatpak
    ccls
    fish
    zoxide
    qbittorrent
    mpc
    picom
    atuin
    bat
    oh-my-fish
    nodejs
    fastfetch
    tree-sitter
    nixd
    zip
    unzip
    git
    gnumake
    gcc
    v4l-utils
    guvcview
    wget
    gtk3
    librewolf
    mpv
    vial
    htop
    playerctl
    proton-vpn
    dunst
    (aspellWithDicts (dicts: with dicts; [ en fr ]))
    emacs
    xrdb
    xsetroot
    xss-lock
    unclutter
    dbus
    xrandr
    gdb
    tex
    cmake
    libtool
    ripgrep
    bluetuith
    pavucontrol
  ] ++ [ factorio-fhs ];
}
