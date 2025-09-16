{ pkgs, ... }:

{
  # Define all system level packages to be added
  environment = {
    systemPackages = with pkgs; [
      kdePackages.krdc
      kdePackages.partitionmanager
      keepassxc
      microsoft-edge
		powershell
    ];
  };
}
