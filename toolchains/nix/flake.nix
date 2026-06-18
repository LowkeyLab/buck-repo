{
  description = "Nix outputs consumed by the Buck Haskell toolchain";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system:
          f (import nixpkgs { inherit system; }));
    in
    {
      packages = forAllSystems (pkgs:
        let
          ghcWithPackages = import ./ghc-with-packages.nix { inherit pkgs; };
        in
        {
          ghc = ghcWithPackages;
          haddock = ghcWithPackages;
          python = pkgs.python3;
          bash = pkgs.bash;
          cxx = pkgs.stdenv.cc;
          default = ghcWithPackages;
        });

      checks = forAllSystems (pkgs:
        let
          ghcWithPackages = import ./ghc-with-packages.nix { inherit pkgs; };
        in
        {
          ghcWithPackages = ghcWithPackages;
        });
    };
}
