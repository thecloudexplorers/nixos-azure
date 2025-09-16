{ inputs, pkgs, ... }:

{
  programs = {
    vscode = {
      enable = true;
      # Prefer vscode packaged by MSFT? Use pkgs.vscode
      # Using vscodium here as open source element of the sovereign workplace
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        # Most extensions should work except packs and should all be downcased
        jnoortheen.nix-ide
        redhat.vscode-yaml
        yzhang.markdown-all-in-one
        github.vscode-pull-request-github
        ms-python.python
        ms-vscode.powershell
      ];
    };
  };
}
