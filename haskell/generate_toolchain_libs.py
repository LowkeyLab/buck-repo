#!/usr/bin/env python3
"""Generate Buck and Nix package lists for Nix-backed Haskell toolchain deps."""

import argparse
import json
from pathlib import Path


HEADER = """# THIS FILE IS AUTO-GENERATED -- DO NOT EDIT --
#
# Regenerate with: buck2 bxl haskell/toolchain.bxl:libs
"""


def _unique_sorted(values):
    return sorted({str(value) for value in values})


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True, type=argparse.FileType("r"))
    parser.add_argument("--output", required=True, type=argparse.FileType("w"))
    args = parser.parse_args()

    libs = _unique_sorted(json.load(args.input))

    bzl_items = "\n".join(f'    "{lib}",' for lib in libs)
    Path("toolchains/libs.bzl").write_text(
        f"""{HEADER}

toolchain_libraries = [
{bzl_items}
]
"""
    )

    nix_items = "\n".join(f'  "{lib}"' for lib in libs)
    Path("toolchains/nix/ghc-toolchain-libraries.nix").write_text(
        f"""{HEADER}

[
{nix_items}
]
"""
    )

    print("ok", file=args.output)


if __name__ == "__main__":
    main()
