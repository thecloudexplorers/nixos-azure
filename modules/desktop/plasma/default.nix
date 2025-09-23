{ lib, pkgs, ... }:

{
  services = {
    desktopManager = { plasma6 = { enable = true; }; };
    displayManager = {
      autoLogin = { enable = false; };
      # Default session options are plasma or plasmax11
      defaultSession = "plasma";
      sddm = {
        enable = true;
        autoNumlock = true;
        # Explicitly disable Wayland as it caused issues
        wayland = { enable = false; };
      };
    };
    # Utilize Plasma/X11 as desktop environment,
    # instead of Wayland. Wayland can cause some
    # RDP issues.
    xserver = {
      enable = true;
      xautolock = {
        enable = true;
        killtime = 10;
      };
    };
    # Configure Remote Desktop Protocol,
    # using Plasma/X11.
    xrdp = {
      enable = lib.mkForce true;
      port = 3389;
      openFirewall = lib.mkDefault true;
      # Explicitly ensure xRDP start Plasma/X11
      defaultWindowManager = "startplasma-x11";
      audio = { enable = true; };
    };
  };
  environment = {
    systemPackages = with pkgs; [
      # Basic IT Ops tooling
      kdePackages.krdc
      kdePackages.partitionmanager
    ];
    plasma6 = {
      # Keep the environment light. No need
      # to add these packages to a developer
      # image (at this time).
      excludePackages = with pkgs; [
        kdePackages.elisa
        kdePackages.gwenview
        kdePackages.kate
        kdePackages.khelpcenter
        kdePackages.okular
        kdePackages.spectacle
      ];
    };
  };
}
