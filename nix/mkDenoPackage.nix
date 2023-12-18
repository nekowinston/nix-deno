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
  ...
} @ args: let
  runtimeArgs = denoPlatform.lib.generateFlags {
    inherit permissions unstable additionalDenoArgs;
    # since we're running a bundled script, the args are passed to the shebang rather than loading an entrypoint from the filesystem.
    entryPoint = "";
  };
in
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
