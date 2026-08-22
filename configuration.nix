# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "zach-nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  nix.settings.experimental-features = [ "nix-command" "flakes"];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."zach" = {
    isNormalUser = true;
    description = "zach";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

    users.groups.myuser = {};


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    vesktop
    fish
    zoxide
    picom
    atuin
    nodejs
    fastfetch  
    git
    gnumake
    gcc
    wget
    gtk3
    librewolf
    vial
    emacs
    xrdb
    xsetroot
    xss-lock
    i3lock
    unclutter
    picom
    dbus
    xrandr
    gdb
    zathura
    texlive.combined.scheme-medium
    cmake
    libtool
    ripgrep
    mouseless
  ];

 fonts.packages = with pkgs; [
   fira-code
   noto-fonts-color-emoji
   nerd-fonts.symbols-only
 ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

  # Perso
  services.xserver = {
    enable = true;
    libinput = {
      enable = true;
    };
  
    desktopManager = {
      session = [{
        manage = "desktop";
        name = "emacs";
        start = ''
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
	qmk-udev-rules # the only relevant
	qmk_hid
	via
	vial
    ]; # packages
  }; # udev

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # fish
  programs.fish = {
    enable = true;
  };

  users.users.zach = {
    shell = pkgs.fish;
  };

}
