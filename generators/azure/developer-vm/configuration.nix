{ ... }:

{
  # Use the import to add even more split modules into the config
  imports = [ ../../../modules/desktop ../../../modules/development ../../../modules/system ];
  # set disk size to to 128G | As per Standard SSD E10
  # Note! When generating VHD files, it gets allocated to memory before
  # dumping into a file. If you have 32GB of RAM (incl. possible swap),
  # you will get an out of memory error when generating the VHD image.
  virtualisation = { diskSize = 128 * 1024; };
  # Set a generic started networking hostname.
  networking = { hostName = "nixos-azure-developer-x"; };
  users = {
    users = {
      "initialuser" = {
        name = "initialuser";
        enable = true;
        group = "users";
        createHome = true;
        extraGroups = [ "wheel" ];
        isNormalUser = true;
        # Mutable passwords needs to be true for this to work
        initialPassword = "ChangeMePlease!";
        openssh = {
          authorizedKeys = {
            keys = [
              # TODO: Add keys here for passwordless authentication
            ];
          };
        };
      };
    };
  };
  system = { stateVersion = "25.05"; };
}
