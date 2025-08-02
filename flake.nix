{
  description = "Hello world flake using uv2nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      # This example is only using x86_64-linux
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      # Use Python 3.12 from nixpkgs
      python = pkgs.python312;
    in
    {
      devShells.x86_64-linux = {
        default =
          pkgs.mkShell {
            packages = [
              pkgs.uv
            ];

            env = {
              # Don't create venv using uv
              UV_NO_SYNC = "1";

              # Force uv to use nixpkgs Python interpreter
              UV_PYTHON = python.interpreter;

              # Prevent uv from downloading managed Python's
              UV_PYTHON_DOWNLOADS = "never";
            };

            shellHook = ''
              # Undo dependency propagation by nixpkgs.
              unset PYTHONPATH

              # Get repository root using git. This is expanded at runtime by the editable `.pth` machinery.
              export REPO_ROOT=$(git rev-parse --show-toplevel)
            '';
          };
      };
    };
}
