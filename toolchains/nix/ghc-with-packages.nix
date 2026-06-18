{ pkgs }:

let
  libraries = import ./ghc-toolchain-libraries.nix;
  hsPkgs = pkgs.haskellPackages;
in
hsPkgs.ghcWithPackages (ps:
  map (name:
    if builtins.hasAttr name ps
    then builtins.getAttr name ps
    else throw "Haskell package '${name}' is not available in nixpkgs.haskellPackages"
  ) libraries)
