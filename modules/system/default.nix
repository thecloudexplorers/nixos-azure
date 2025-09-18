{ lib, pkgs, ... }:

{
  # Define all system level packages to be added
  environment = {
    systemPackages = with pkgs; [
      # Basic IT Ops tooling
      dig
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
  services = {
    openssh = {
      enable = true;
      ports = [ 22 22022 ];
      openFirewall = true;
    };
  };
  programs = {
    ssh = {
      startAgent = true;
    };
  };
}
