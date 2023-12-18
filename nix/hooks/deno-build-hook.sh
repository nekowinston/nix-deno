# shellcheck shell=bash disable=SC2016

denoBuildHook() {
  echo "Executing denoBuildHook"

  runHook preBuild

  local -r depsOut="$out/lib/deno_dir"

  if [ -z "${denoBuildTask-}" ]; then
    echo
    echo "ERROR: no build task was specified"
    echo 'Hint: set `denoBuildTask`, override `buildPhase`, or set `dontDenoBuild = true`.'
    echo
    exit 1
  fi

  if ! deno task "$denoBuildTask"; then
    echo
    echo "ERROR: build task failed"
    echo
    echo 'Make sure that the `deno.json` file exists and that the specified task is valid.'
    exit 1
  fi

  runHook postBuild

  echo "Finished denoBuildHook"
}

if [ -z "${dontDenoBuild-}" ] && [ -z "${buildPhase-}" ]; then
  buildPhase=denoBuildHook
fi
