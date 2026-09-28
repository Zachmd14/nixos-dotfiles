{ config
, lib
, pkgs
, ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "zach-nixos";

  # Intel CPU. Remove this line on an AMD host.
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Panel Self Refresh and display C-states cause flicker on this laptop.
  boot.kernelParams = [ "i915.enable_psr=0" "i915.enable_dc=0" ];
}
