{ pkgs, perSystem }:
pkgs.mkShell {
  packages = [
    (pkgs.ghc.withPackages (p: perSystem.self.blup.buildInputs))
    pkgs.cabal-install
    pkgs.hpack
    pkgs.ghciwatch
  ];
}
