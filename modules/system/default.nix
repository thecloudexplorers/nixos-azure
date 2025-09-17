{ lib, pkgs, ... }:

{
  # Define all system level packages to be added
  environment = {
    systemPackages = with pkgs; [
      # Basic IT Ops tooling
      dig
      kdePackages.krdc
      kdePackages.partitionmanager
      netcat
      nmap
      openssl
      # Package for secrets management
      keepassxc
      # Add the following Microsoft packages
      microsoft-edge
      microsoft-identity-broker
      powershell
      # Various development tools/packages
      beekeeper-studio # For any type of SQL ops
      hugo
      nixfmt-classic
      nixos-generators
      nixos-option
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
  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "microsoft-edge"
          "microsoft-identity-broker"
          "vscode"
          "vscode-with-extensions"
        ];
      # As an example, how to include insecure packages
      # including beekeeper studio here. Why is it
      # marked as insecure? Electron version 31.
      # More information here:
      # https://github.com/beekeeper-studio/beekeeper-studio/issues/2968
      permittedInsecurePackages = [ "beekeeper-studio-5.3.4" ];
    };
  };
}
