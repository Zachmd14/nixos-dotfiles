{ inputs
, config
, pkgs
, username
, ...
}:

{
  imports = [
    ../apps/firefox.nix
  ];
  # Use a function instead of an alias
  home.sessionVariables = {
    DEMUCS_BIN = "${config.home.homeDirectory}/.venvs/demucs/bin/demucs";
  };

  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.stateVersion = "26.05";

  programs.git.enable = true;

  programs.fish = {
    enable = true;
    binds = {
      "up".command = "up-or-search";
    };

    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake $HOME/nixos-flakes";
      snr = "sudo nix run nixpkgs#";

      mann = "MANPAGER='less -N --use-color -Dd+y -Du+208 -DN+r' man";

      cd = "z";

      gtp = "git push origin main";
      gta = "git add .";
      gtc = "git commit -m";

      battery = "acpi -b";

      piweb = "npm start --prefix ~/Documents/pi-webui";

      e = "emacsclient -n";
    };


    interactiveShellInit = ''
      set -gx EDITOR "nano"
      set -gx PAGER less
      set -g fish_greeting ""
    '';
    functions = {
      ddemucs = {
        body = ''
          set -lx LD_LIBRARY_PATH (nix eval --raw nixpkgs#stdenv.cc.cc.lib.outPath)/lib $LD_LIBRARY_PATH
          ~/.venvs/demucs/bin/demucs -d cpu -o ~/Music/stem $argv
        '';
        description = "Run demucs on the given file";
      };
    };
  };

  programs.atuin = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  services.syncthing.enable = true;

  programs.home-manager.enable = true;

  programs.pi-coding-agent = {
    enable = true;
    models = {
      providers = {
        deepseek = {
          models = [
            {
              id = "deepseek-v4-pro";
            }
          ];
          apiKey = "see secret";
        };
      };
    };
  };
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  xdg.configFile."picom/picom.conf".text = ''
    #################################
    #
    # Backend
    #
    #################################

    # Backend to use: "xrender" or "glx".
    # GLX backend is typically much faster but depends on a sane driver.

    # backend = "xrender";
    # backend = "xr_glx_hybrid";
    backend = "xrender";
  '';

}
