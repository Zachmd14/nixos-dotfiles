{ pkgs, username, ... }:

{
  imports = [
    ./minimal-packages.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  programs.nix-ld.enable = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  nix.extraOptions = ''
    warn-dirty = false
    keep-outputs = true
  '';

  # Dropped: services.flatpak.enable
  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
  ];

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };

  hardware.uinput.enable = true;

  # Dropped: docker, kvm, libvirt groups.
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "networkmanager" "audio" "wheel" "uinput" "video" ];
    shell = pkgs.fish;
    packages = with pkgs; [ ];
  };

  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    fira-code
    noto-fonts-color-emoji
    nerd-fonts.symbols-only
  ];

  system.stateVersion = "26.05";

  services.xserver = {
    enable = true;
    enableTearFree = true;
    libinput = {
      enable = true;
    };

    desktopManager = {
      session = [{
        manage = "desktop";
        name = "emacs";
        start = ''
          picom --config ~/.config/picom/picom.conf &
          xss-lock -- i3lock -n &
          xset s 600 600
          xset dpms 600 600 600
          dunst &
          unclutter -idle 3 &

          export VISUAL="emacsclient"
          export EDITOR="emacsclient"

          ${pkgs.emacs}/bin/emacs --daemon --init-directory ~/.config/emacs

          while ! ${pkgs.emacs}/bin/emacsclient -e '(message "ready")' &>/dev/null; do
            sleep 0.1
          done

          ${pkgs.emacs}/bin/emacsclient -c &
          waitPID=$!;
        '';
      }];
    };

    displayManager.defaultSession = "emacs";
  };

  # Dropped: qmk (2.1 GiB), qmk_hid (0.18 GiB), via, and Vial (1.5 GiB).
  # qmk-udev-rules is 4.7 KiB and the Vial rule is inlined below.
  services.udev = {
    packages = with pkgs; [
      qmk-udev-rules
    ];
  };

  programs.i3lock.enable = true;

  # rtkit (optional, recommended) allows Pipewire to use the realtime scheduler for increased performance.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.fish.enable = true;

  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main = {
        capslock = "overload(control, esc)";
      };
    };
  };

  # Make sysfs backlight brightness writable by the `video` group.
  # GROUP=/MODE= do not work here: backlight has no device node, only sysfs
  # attribute files, so we chgrp/chmod the brightness file on add events.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"

    # Vial/VIA keyboard access (from pkgs.vial, kept without the 1.5 GiB app).
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", TAG+="uaccess", TAG+="udev-acl"
  '';

  # Dropped: virtualisation.docker, virtualisation.libvirtd,
  # virtualisation.spiceUSBRedirection, programs.virt-manager.

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 75;

      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 90;
      START_CHARGE_THRESH_BAT1 = 40;
      STOP_CHARGE_THRESH_BAT1 = 90;
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Dropped: networking.firewall ports, networking.hosts, services.httpd,
  # services.postgresql, programs.gamemode.

  systemd.tmpfiles.rules = [
    "z /home/${username} 0711 ${username} users - -"
  ];

  environment.etc."wireplumber/wireplumber.conf.d/51-flx4.conf".text = ''
    monitor.alsa.rules = [
      {
        matches = [ { node.name = "alsa_output.usb-AlphaTheta_Corporation_DDJ-FLX4_EGKG076672NN-00.analog-surround-40" } ]
        actions = {
          update-props = {
            audio.position = "AUX0,AUX1,AUX2,AUX3"
          }
        }
      }
    ]
  '';

  services.displayManager.ly.enable = true;

  # speech-dispatcher is enabled by default (via services.graphical-desktop)
  # and pulls 0.72 GiB of MBROLA/Espeak voices. Not needed for a WM test.
  services.speechd.enable = false;
}
