{
  lib,
  deno,
  denoPlatform,
}: {
  name,
  permissions ? {},
  unstable ? false,
  entryPoint ? "main.ts",
  binaryName ? name,
  additionalDenoArgs ? [],
  denoBundle ? false,
  ...
} @ args: let
  runtimeArgs = denoPlatform.lib.generateFlags {
    inherit permissions unstable additionalDenoArgs;
  };
in
  # TODO: rework this to use nativebuildinputs / denoPlatform hooks
  denoPlatform.mkDenoDerivation ({
      # TODO: investigate other bundlers like `deno_emit`, since `deno bundle` is deprecated
      buildPhase = ''
        deno bundle ${entryPoint} "$TMPDIR"/${binaryName}
      '';

      installPhase = ''
        mkdir -p $out/bin
        cp "$TMPDIR"/${binaryName} $out/bin/${binaryName}
        sed -i -e "1i#!${lib.getExe deno} run ${runtimeArgs}" $out/bin/${binaryName}
        chmod +x $out/bin/${binaryName}
      '';

      runtimeInputs = [deno];

      # default to Deno's platforms
      meta.platforms = deno.meta.platforms;
    }
    // (builtins.removeAttrs args ["permissions"]))
