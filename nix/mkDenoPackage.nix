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
  scriptArgs ? "",
  ...
} @ args: let
  runtimeArgs = denoPlatform.lib.generateFlags {
    inherit permissions unstable entryPoint additionalDenoArgs scriptArgs;
  };
  wrapper = ''
    #!${lib.getExe deno} run ${runtimeArgs}

    $out/${entryPoint} $scriptArgs
  '';
in
  denoPlatform.mkDenoDerivation ({
      dontBuild = true;

      installPhase = ''
        cp -r $src $out
        chmod +w $out

        mkdir -p $out/bin
        echo "${wrapper}" > $out/bin/${binaryName}
        chmod +x $out/bin/${binaryName}
      '';

      runtimeInputs = [deno];

      # default to Deno's platforms
      meta.platforms = deno.meta.platforms;
    }
    // args)
