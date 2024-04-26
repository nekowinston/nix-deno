{
  lib,
  makeWrapper,
  deno,
  denoPlatform,
}: {
  name,
  permissions ? {},
  include ? [],
  unstable ? false,
  entryPoint ? "main.ts",
  binaryName ? name,
  additionalDenoArgs ? [],
  scriptArgs ? [],
  ...
} @ args: let
  compileArgs = denoPlatform.lib.generateFlags {
    inherit permissions unstable include;
    additionalDenoArgs = additionalDenoArgs ++ ["--output" binaryName entryPoint] ++ scriptArgs;
  };
in
  denoPlatform.mkDenoDerivation ({
      nativeBuildInputs = [makeWrapper];
      buildPhase = ''
        runHook preBuild
        deno compile ${compileArgs}
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        install -Dm755 ${binaryName} $out/bin/${binaryName}
        runHook postInstall
      '';

      # fixup corrupts the binary, leaving it in a Deno REPL-only state
      dontFixup = true;
    }
    // (builtins.removeAttrs args ["permissions" "unstable" "include"]))
