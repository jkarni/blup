{ pkgs, ... }:

pkgs.haskellPackages.callCabal2nix "blup" ../../.. { }
