# Buck2 Haskell Nix Scaffold

This repository is a minimal Haskell example intended to be built with Buck2 from a Nix flake development shell.

## Development shell

Enter the shell with:

```sh
nix develop
```

The shell provides the tooling needed for this scaffold, including:

- `buck2`
- `ghc`
- `ghc-pkg`
- `haddock`

These tools are used by Buck2's bundled demo Haskell toolchain for minimal local experimentation. The demo toolchain is suitable for scaffolding, but it is not a production-grade Haskell toolchain policy.

## Optional direnv integration

If you use direnv, allow the checked-in `.envrc` once from the repository root:

```sh
direnv allow
```

The `.envrc` uses `use flake`, so direnv will load the same Nix development shell automatically.

## Build

Build the example Haskell binary with:

```sh
nix develop -c buck2 build //haskell_hello_world:main --show-output
```

The target is defined in `haskell_hello_world/BUCK` and points at `haskell_hello_world/Main.hs`.

## Validation commands

Run these checks from the repository root when validating the scaffold:

```sh
nix flake check
nix develop -c ghc --version
nix develop -c ghc-pkg --version
nix develop -c haddock --version
nix develop -c buck2 build //haskell_hello_world:main --show-output
git diff --check
```
