{pkgs ? import <nixpkgs> {overlays = [(import ../../nix)];}}:
pkgs.denoPlatform.mkDenoDir ./deno.lock
