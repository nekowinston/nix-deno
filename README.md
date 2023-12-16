<p align="center">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="./.github/assets/nix-deno-dark.webp" width="250">
      <source media="(prefers-color-scheme: light)" srcset="./.github/assets/nix-deno-light.webp" width="250">
      <img alt="Logo" src="./.github/assets/nix-deno-dark.webp" width="250">
    </picture>
    <h3 align="center">nix-deno</h3>
</p>

Nix builders for [Deno](https://deno.land) projects.

Still a WIP, but here's what works / is done:

- [x] `denoPlatform.mkDenoDir`: cache Deno dependencies in a pure Nix expression, no external scripts needed.
- [x] Scripts without dependencies.
- [x] https://deno.land, https://esm.sh dependencies.
- [x] NPM dependencies, for the most part. I use this repo to build my [Lume](https://lume.land) website, which has a lot of NPM dependencies, but I'm 100% sure there will be edge cases.
- [x] `denoPlatform.mkDenoDerivation`: a basic `stdenv.mkDerivation` wrapper that handles dependencies for you.
- [ ] helpers/builders for `deno compile`, or bundling.
- [ ] more helpful docs, right now, I'd suggest having a look at [`./ci.nix`](./ci.nix) for basic usage info.
- [ ] a release.

## License

[MIT](./LICENSE)

---

I love Deno. 🥰