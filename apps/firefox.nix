{ inputs, ... }:

{
  programs.librewolf = {
    enable = true;
    profiles.default = {
      isDefault = true; # <-- Forces LibreWolf to use THIS profile
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;
        "layout.css.has-selector.enabled" = true;
        "browser.urlbar.suggest.calculator" = true;
        "browser.urlbar.unitConversion.enabled" = true;
        "browser.urlbar.trimHttps" = true;
        "browser.urlbar.trimURLs" = true;
        "browser.profiles.enabled" = true;
        "widget.gtk.rounded-bottom-corners.enabled" = true;
        "browser.compactmode.show" = true;
        "widget.gtk.ignore-bogus-leave-notify" = 1;
        "browser.tabs.allow_transparent_browser" = true;
        "browser.uidensity" = 1;
        "browser.aboutConfig.showWarning" = false;
      };
    };
  };

  # Home Manager places the 'default' profile exactly here:
  home.file.".librewolf/default/chrome" = {
    source = "${inputs.potatofox}/chrome";
    recursive = true;
  };
}
