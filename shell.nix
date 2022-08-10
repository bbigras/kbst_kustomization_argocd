{ pkgs, pre-commit-hooks, system }:

with pkgs;

let
  pre-commit-check = pre-commit-hooks.lib.${system}.run {
    src = ./.;
    hooks = {
      nixpkgs-fmt.enable = true;
      nix-linter.enable = true;
      statix.enable = true;
      terraform-format.enable = true;
    };
    excludes = [
    ];
  };
in
mkShell {
  buildInputs = [
    kustomize
    terraform
  ];

  shellHook = ''
    ${pre-commit-check.shellHook}
  '';
}
