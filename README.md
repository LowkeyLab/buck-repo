# Buck2 Rust Nix Scaffold

This repository is a minimal Rust example intended to be built with Buck2 from a Nix flake development shell.

## Development shell

Enter the shell with:

```sh
nix develop
```

The shell provides:

- `buck2`
- `rustc`
- `cargo`
- `rustfmt`
- `clang` / `clang++`
- `lld` / `ld.lld`

`clang` and `lld` are included because Buck2's bundled demo Rust toolchain expects system compiler/linker tools for this minimal local scaffold.

## Optional direnv integration

If you use direnv, allow the checked-in `.envrc` once from the repository root:

```sh
direnv allow
```

The `.envrc` uses `use flake`, so direnv will load the same Nix development shell automatically.

## Build

Build the example Rust binary with:

```sh
buck2 build //:main --show-output
```

The target is defined in `BUCK.v2` and points at `src/main.rs`.

This scaffold uses Buck2's bundled prelude and demo toolchain definitions in `toolchains/BUCK.v2` via `system_demo_toolchains()`. Those demo toolchains are suitable for minimal scaffolding and local experimentation, but they are not a production-grade toolchain policy.

## Validation commands

Run these checks from the repository root:

```sh
nix flake check
nix develop -c buck2 --version
nix develop -c rustc --version
nix develop -c sh -c 'command -v clang++ && command -v ld.lld'
nix develop -c buck2 build //:main --show-output
git diff --check
```
