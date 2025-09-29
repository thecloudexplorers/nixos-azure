# Source Code

This folder, src/, contains all source code relevant to this project. The structure is broken down into major source code languages.

Most pertinent to this project:
- Nix
- PowerShell

## Nix

Please note that the Nix Flake contained in this repo is built from the src/nix/flake.nix location. It does not start at the repo root level due to our default folder structure.

All Nix code files (.nix) are formatted using `nixfmt-classic` formatting package and subsequent style rules.

## PowerShell

Our PowerShell scripts are formatted and written using the "One True Brace"  standard. Our .vscode settings.json file enforces it, with additional formatting changes.
