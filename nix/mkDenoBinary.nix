{
  lib,
  deno,
  denoPlatform,
}: {
  name,
  allow ? [],
  unstable ? false,
  entryPoint ? "main.ts",
  binaryName ? name,
  additionalFlags ? [],
  scriptArguments ? "",
  ...
} @ args: let
  compileArgs = builtins.concatStringsSep " " (lib.flatten [
    (map (flag: "--allow-${flag}") allow)
    (
      if binaryName
      then "--output ${binaryName}"
      else ""
    )
    (
      if unstable
      then "--unstable"
      else ""
    )
    entryPoint
    scriptArguments
  ]);
in
  denoPlatform.mkDenoDerivation ({
      # fixup corrupts the binary, leaving it in a Deno REPL-only state
      dontFixup = true;

      buildPhase = "deno compile ${compileArgs}";
      installPhase = "install -Dm755 ${binaryName} $out/bin/${binaryName}";

      # default to Deno's platforms
      meta.platforms = deno.meta.platforms;
    }
    // args)
