{ lib, ... }:

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
        wayland = {
          enable = true;
          # Compositor options: kwin, weston
          compositor = "weston";
        };
      };
    };
    # Explicitly *disable* xserver, so you don't
    # get Plasma/Wayland && Plasma/X11.
    xserver = { enable = false; };
    # Configure Remote Desktop Protocol,
    # using Plasma/Wayland.
    xrdp = {
      enable = lib.mkForce true;
      port = 3389;
      openFirewall = true;
      defaultWindowManager = "startplasma-wayland";
      audio = { enable = true; };
    };
  };
}
