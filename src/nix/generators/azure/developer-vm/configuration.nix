{ ... }:

{
  # Use the import to add even more split modules into the config
  imports = [
    ../../../modules/desktop # All basic desktop modules
    ../../../modules/development # All development related tools
    ../../../modules/system # All basic system settings
    ../../../modules/users # All required users
  ];
  # set disk size to to 128G | As per Standard SSD E10
  # Note! When generating VHD files, it gets allocated to memory before
  # dumping into a file. If you have 32GB of RAM (incl. possible swap),
  # you will get an out of memory error when generating the VHD image.
  virtualisation = { diskSize = 128 * 1024; };
  # Set a generic started networking hostname.
  networking = {
    # This can be changed for individual hosts later
    # however this is an image to be used for
    # multiple machines. Specific configurations
    # can be applied per *instance* of the image
    hostName = "nixos-azure-developer-x";
  };
  system = { stateVersion = "25.05"; };
  virtualisation = {
    azureImage = {
      bootSize = 512;
      vmGeneration = "v1";
    };
  };
}
