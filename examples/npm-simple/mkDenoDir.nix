{
  pkgs ?
    import <nixpkgs> {
      overlays = [
        (self: super: {
          denoPlatform = self.callPackage ../../nix {};
        })
      ];
    },
}:
pkgs.denoPlatform.mkDenoDir ./deno.lock
