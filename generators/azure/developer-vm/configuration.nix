{ ... }:

{
  # Use the import to add even more split modules into the config
  imports = [ ];
  networking = { hostname = "nixos-azure-developer-x"; };
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
