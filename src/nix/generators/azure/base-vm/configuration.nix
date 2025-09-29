{ ... }:

{
  # Use the import to add even more split modules into the config
  imports = [ ];
  # set disk size to to 32G | As per Standard SSD E4
  virtualisation = { diskSize = 32 * 1024; };
  # Set a generic started networking hostname.
  networking = { hostName = "nixos-azure-base-x"; };
  # The only real addition to the base image we're doing here
  # is the user so we can log into the machine. In more advanced
  # configurations this is where you'd add specific options
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
