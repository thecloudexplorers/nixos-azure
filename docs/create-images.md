# Create NixOS installer images

## Flake approach

Include something like the following in your flake, to generate OS images directly from the flake:

``` nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixos-generators, ... }: {
    packages.x86_64-linux = {
      azurevm = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        modules = [
        {
          # set disk size to to 32G | As per Standard SSD E4
          virtualisation.diskSize = 128 * 1024;
        }
        ./generators/azure/base-vm/configuration.nix
        ];
        format = "azure";
      };
      vmware = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        modules = [
          # you can include your own nixos configuration here, i.e.
          # ./configuration.nix
        ];
        format = "vmware";
        
        # optional arguments:
        # explicit nixpkgs and lib:
        # pkgs = nixpkgs.legacyPackages.x86_64-linux;
        # lib = nixpkgs.legacyPackages.x86_64-linux.lib;
        # additional arguments to pass to modules:
        # specialArgs = { myExtraArg = "foobar"; };
        
        # you can also define your own custom formats
        # customFormats = { "myFormat" = <myFormatModule>; ... };
        # format = "myFormat";
      };
      vbox = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        format = "virtualbox";
      };
    };
  };
}
```

When you want to build this image and output it in a file, run the following:
`nix build ~/path/to/repo#<config-name>`

This will then output the ISO/VM image into the `./result/<format>/<file.format>` folder.

In the case of the Azure VM image in the above example, use `nix build ~/path/to/repo#azurevm`

## Manual approach

If you wish to build the image manually, without a flake and by directly using nixos-generate, the following example demonstrates that. In this case it is an ISO example, but any nixos-generate format is supported in the same way.

> Pre-requisite: Have NixOS-Generators installed.

1. Define `/path/to/image/myimage.nix`
2. Run the following, `nixos-generate --format iso --configuration ./path/to/image/myimage.nix -o result`
3. Copy to USB drive: `dd if=result/iso/*.iso of=/dev/sdX status=progress` & `sync`

### myimage.nix content

The following content is part of the `myimage.nix` definition.

``` nix
{ pkgs, modulesPath, lib, ... }: {
    imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ];

    # use the latest Linux kernel
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # Needed for https://github.com/NixOS/nixpkgs/issues/58959
    boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];
}
```

## ISO data dump to USB drive

In order to write the ISO image to a thumb drive, the `dd` utility (also known as 'disk destroyer', 'disk duplicator', or 'data dump') can be used.

The following command will write the ISO image to a thumbdrive:
`sudo dd if=/path/to/nixos-installer.iso of=/dev/sdX bs=4M conv=fsync oflag=direct status=progress`

Be sure to replace the `if` parameter with the correct source, and the `of` parameter with the correct target drive.

> Take note! The targeted disk will be erased, do not swap the parameters around. Or you will find out why the tool is referred to as the 'disk destroyer'.
