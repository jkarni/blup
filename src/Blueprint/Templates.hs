{-# LANGUAGE QuasiQuotes #-}
module Blueprint.Templates where

import Data.String.Interpolate (i)
import Blueprint.CLIOptions

basicPackage :: String
basicPackage = [i|{ pkgs, perSystem, ... }:

|]

basicCheck :: String
basicCheck = [i|{ pkgs, perSystem, ... }:

|]

basicDevShell :: String
basicDevShell = [i|{ pkgs, perSystem, ... }:
pkgs.mkShell {
  packages = [ ];
}
|]

basicNixosConfig :: String
basicNixosConfig = [i|{ flake, inputs, perSystem, ... }:
{
  imports = [
  ];

  environment.systemPackages = [
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "24.05";
}
|]

basicFlake :: NixpkgsVersion -> String
basicFlake version = [i|
{
  description = "my flake";

  # Add all your dependencies here
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=#{nixpkgsVersion version}";
    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Load the blueprint
  outputs = inputs: inputs.blueprint {
    inherit inputs;
    prefix = ./nix;
  };
}
|]

nixpkgsVersion :: NixpkgsVersion -> String
nixpkgsVersion v = case v of
  NixosUnstable -> "nixos-unstable"
  Nixos2311 -> "nixos-23.11"
  Nixos2311Small -> "nixos-23.11-small"
  Nixos2405 -> "nixos-24.05"
  Nixos2405Small -> "nixos-24.05-small"

