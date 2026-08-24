{ config, pkgs, ... }:

{
  home.username = "zach";
  home.homeDirectory = "/home/zach";

  home.stateVersion = "26.05"; # Please read the comment before changing.

  programs.git.enable = true;

  programs.fish = {
    enable = true;
    binds = { };

    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake";
      mann = "MANPAGER='less -N --use-color -Dd+y -Du+208 -DN+r' man";
    };

    functions = { };


    interactiveShellInit = ''
      set -gx EDITOR "nano"
      set -gx PAGER less
      set -g fish_greeting ""
    '';
  };



  programs.atuin = {
    enable = true;
    # ...
    flags = [ "--disable-up-arrow" ]; # or --disable-ctrl-r
  };


  programs.home-manager.enable = true;
}
