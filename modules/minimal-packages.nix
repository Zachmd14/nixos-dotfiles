{ pkgs, ... }:

{
  # Minimum needed by the current config, plus EWM runtime deps.
  environment.systemPackages = with pkgs; [
    # Called by name in modules/system.nix session script.
    emacs
    picom
    dunst
    unclutter
    xss-lock

    # EWM (Wayland) runtime requirements.
    wl-clipboard          # wl-copy / wl-paste for clipboard
    brightnessctl         # brightness/media keys
  ];
}
