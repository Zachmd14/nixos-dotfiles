{ config, pkgs, inputs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./packages.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "zach-nixos";
  programs.nix-ld.enable = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  nix.extraOptions = ''
    warn-dirty = false
    keep-outputs = true
  '';

  services.flatpak.enable = true;
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
    # altgr-intl : layout US normal, mais Alt droite = AltGr avec dead keys :
    #   AltGr+` puis a -> à      AltGr+' puis e -> é
    #   AltGr+Shift+' puis e -> ë   AltGr+6 puis e -> ê
    # ' et ` restent littéraux sans AltGr (pratique pour coder).
    variant = "altgr-intl";
  };


  hardware.uinput.enable = true;

  users.users."zach" = {
    isNormalUser = true;
    description = "zach";
    extraGroups = [ "docker" "kvm" "vkc" "libvirt" "networkmanager" "audio" "wheel" "uinput" "video" ];
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
                    	  flatpak run net.sonuscape.mouseless &
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

  services.udev = {
    packages = with pkgs; [
      qmk
      qmk-udev-rules
      qmk_hid
      via
      vial
    ];
  };

  programs.i3lock.enable = true;

  # rtkit (optional, recommended) allows Pipewire to use the realtime scheduler for increased performance.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true; # if not already enabled
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment the following
    #jack.enable = true;
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

  programs.gamemode.enable = true;

  # Make sysfs backlight brightness writable by the `video` group so
  # Emacs (backlight.el) and other user tools can adjust it.
  # GROUP=/MODE= don't work here: backlight has no device node, only sysfs
  # attribute files, so we chgrp/chmod the brightness file on add events.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
  '';


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

  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = [ "zach" ];

  virtualisation.libvirtd.enable = true;

  virtualisation.spiceUSBRedirection.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  networking.firewall.allowedTCPPorts = [ 2234 80 8080 443 ];
  networking.hosts = {
    "127.0.0.1" = [ "mysite.localhost" "php.localhost" ];
  };
  services.httpd = {
    enable = true;
    adminAddr = "zach@zach-nixos";
    enablePHP = true;

    virtualHosts.localhost = {
      documentRoot = "/srv/http";
      listen = [
        { ip = "*"; port = 80; }
      ];
    };

    virtualHosts.mysite = {
      documentRoot = "/srv/http/mysite";
      listen = [
        { ip = "*"; port = 8080; }
      ];
    };

    virtualHosts."php.localhost" = {
      hostName = "php.localhost";
      documentRoot = "/srv/http/TP_PHP";
      listen = [
        { ip = "*"; port = 80; }
      ];

      extraConfig = ''
        # 4.b.4 : .htaccess peut modifier les Options
        # <Directory "/srv/http/TP_PHP">
        #   AllowOverride All
        # </Directory>

        # 4.b.2 : refuser le listing de test2 via la config Apache
        # <Directory "/srv/http/TP_PHP/test2">
        #   Options -Indexes
        # </Directory>

        # 4.b.3 : refuser test1, autoriser test2 via la config Apache
        # <Directory "/srv/http/TP_PHP/test1">
        #   Options -Indexes
        # </Directory>
        # <Directory "/srv/http/TP_PHP/test2">
        #   Options Indexes
        # </Directory>
      '';
    };
  };

  systemd.tmpfiles.rules = [
    "z /home/zach 0711 zach users - -"
    "d /srv/http 0755 root root - -"
    "d /srv/http/mysite 0755 root root - -"

    # 4.a
    "d /srv/http/TP_PHP 0755 zach users - -"
    "d /srv/http/TP_PHP/test1 0755 zach users - -"
    "d /srv/http/TP_PHP/test2 0755 zach users - -"

    # 4.a
    "L+ /srv/http/TP_PHP/info-php.php - - - - ${pkgs.writeText "info-php.php" "<?php\nphpinfo();\n?>\n"}"
    "L+ /srv/http/TP_PHP/test1/index.html - - - - ${pkgs.writeText "test1-index.html" "<h1>test1</h1>\n"}"
    "L+ /srv/http/TP_PHP/test2/autre.html - - - - ${pkgs.writeText "test2-page.html" "<h1>test2</h1>\n"}"

    # 4.b.4
    "L+ /srv/http/TP_PHP/test2/.htaccess - - - - ${pkgs.writeText "test2-htaccess" "Options -Indexes\n"}"
  ];

  virtualisation.docker.enable = true;

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

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    settings.password_encryption = "scram-sha-256";
  };

  services.postgresql.authentication = lib.mkForce ''
    # TYPE  DATABASE  USER      ADDRESS       METHOD
    local   all       postgres                peer map=postgres
    local   all       all                     scram-sha-256
    host    all       all       127.0.0.1/32  scram-sha-256
    host    all       all       ::1/128       scram-sha-256
  '';

  services.displayManager.ly.enable = true;

  boot.kernelParams = [ "i915.enable_psr=0" "i915.enable_dc=0" ];
}
