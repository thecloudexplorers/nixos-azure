{
  description =
    "Flake for generation of Azure VM Images, and related host configurations.";

  inputs = {
    # NOTE: Replace "nixos-YY.MM" with that which is in system.stateVersion of
    # configuration.nix. You can also use latter versions if you wish to
    # upgrade. Use "nixos-unstable" for the unstable branch of packages.
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-unstable"; };
    # Enable Nix Community generators in this flake
    nixos-generators = {
      url = "github:nix-community/nixos-generators/master";
      inputs = { nixpkgs = { follows = "nixpkgs"; }; };
    };
    # Ensure loading of VS Code extentions directly from the config
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions/master";
    };
    # Load the Cloud Explorer NixOS common definitions here
    nixos-common = { url = "github:thecloudexplorers/nixos-common/main"; };
  };
  outputs = inputs@{ self, nixpkgs, nixos-generators, nixos-common, ... }: {
    packages.x86_64-linux = {
      azureBaseVm = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        specialArgs = { inherit (self) inputs outputs; };
        modules = [
          {
            # Pin nixpkgs to the flake input, so that the packages installed
            # come from the flake inputs.nixpkgs.url
            nix = { registry = { nixpkgs = { flake = nixpkgs; }; }; };
          }
          # Import external repo modules like so:
          nixos-common.nixosModules.localization-en_nl
          # Import separate modules from the local flake like so:
          ./generators/azure/base-vm/configuration.nix
        ];
        format = "azure";
      };
      azureDevVm = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        specialArgs = { inherit (self) inputs outputs; };
        modules = [
          {
            # Pin nixpkgs to the flake input, so that the packages installed
            # come from the flake inputs.nixpkgs.url
            nix = { registry = { nixpkgs = { flake = nixpkgs; }; }; };
          }
          # Import external repo modules like so:
          nixos-common.nixosModules.localization-en_nl
          # Import separate modules from the local flake like so:
          ./generators/azure/developer-vm/configuration.nix
        ];
        format = "azure";
      };
    };
  };
}
