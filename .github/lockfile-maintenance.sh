#!/bin/bash
set -euo pipefail

REPODIR=$(dirname "$(dirname "$(realpath "$0")")")

for example in "$REPODIR"/examples/*; do
  cd "$example" || exit 1
  rm deno.lock || true
  find . -regex '.*\.[jt]sx*' -exec deno cache '{}' \;
done
