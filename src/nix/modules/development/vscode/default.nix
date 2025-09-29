{ inputs, pkgs, ... }:

{
  programs = {
    vscode = {
      enable = true;
      # Prefer vscodium? Use pkgs.vscodium
      package = pkgs.vscode;
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
