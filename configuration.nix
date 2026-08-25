{ config, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./packages.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "zach-nixos";

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
    variant = "";
  };


  hardware.uinput.enable = true;

  users.users."zach" = {
    isNormalUser = true;
    description = "zach";
    extraGroups = [ "networkmanager" "wheel" "uinput" ];
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
                    	  unclutter --timeout 3 &


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

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
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

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "zach" = import ./home.nix;
    };
  };
}
