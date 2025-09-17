{ ... }:

{
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
}
