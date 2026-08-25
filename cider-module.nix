{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.cider;
in
{
  options.modules.cider = with lib; {
    enable = mkEnableOption ''enable cider module'';
    pkg = mkOption {
      type = types.enum [
        "cider"
        "cider-2"
      ];
      default = "cider-2";
      description = ''
        Choose the cider package to use, either the paid (2) or the free version
      '';
    };
  };

  config =
    let
      cider-2 = pkgs.appimageTools.wrapType2 rec {
        pname = "cider-2";
        version = "2.6.1";

        src = pkgs.fetchurl {
          name = "cider-linux-x64.AppImage";
          url = "https://cidercollective.itch.io/cider";
          sha256 = "18by764idifnjs5h2cydv4qjm7w95lzdlxjkscp289w3jdpbmd05";
        };

        nativeBuildInputs = [ pkgs.makeWrapper ];

        extraInstallCommands =
          let
            contents = pkgs.appimageTools.extract {
              inherit version src;
              # HACK: this looks for a ${pname}.desktop, where `cider-2.desktop` doesn't exist
              pname = "Cider";
            };
          in
          ''
            wrapProgram $out/bin/${pname} \
               --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
               --add-flags "--no-sandbox --disable-gpu-sandbox" # Cider 2 does not start up properly without these from my preliminary testing

            install -m 444 -D ${contents}/Cider.desktop $out/share/applications/${pname}.desktop
            substituteInPlace $out/share/applications/${pname}.desktop \
              --replace-warn 'Exec=Cider' 'Exec=${pname}'
            install -Dm444 ${contents}/usr/share/icons/hicolor/256x256/cider-linux----arch-------version---.png \
                           $out/share/icons/hicolor/256x256/apps/cider.png
          '';

        meta = with lib; {
          description = "Powerful music player that allows you listen to your favorite tracks with style";
          homepage = "https://cider.sh";
          license = licenses.unfree;
          mainProgram = "cider-2";
          maintainers = with maintainers; [ itsvic-dev ];
          platforms = platforms.linux;
        };
      };
    in
    lib.mkIf cfg.enable {
      environment.systemPackages =
        if cfg.pkg == "cider" then
          [ pkgs.cider ]
        else if cfg.pkg == "cider-2" then
          [ cider-2 ]
        else
          [ ];
    };
}
