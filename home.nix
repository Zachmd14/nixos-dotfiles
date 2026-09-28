{ inputs, config, pkgs, ... }:

{
  imports = [
    ./apps/firefox.nix
  ];
  # Use a function instead of an alias
  home.sessionVariables = {
    DEMUCS_BIN = "${config.home.homeDirectory}/.venvs/demucs/bin/demucs";
  };

  home.username = "zach";
  home.homeDirectory = "/home/zach";

  home.stateVersion = "26.05";

  programs.git.enable = true;

  programs.fish = {
    enable = true;
    binds = {
      "up".command = "up-or-search";
    };

    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake /home/zach/nixos-flakes";
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
          apiKey = "sk-58c32b21c8f348509a26d264e5b74055";
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

}
