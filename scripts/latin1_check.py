#!/usr/bin/env python3
"""Checks Latin1-managed files for obvious UTF-8 replacement corruption."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent.parent
REPLACEMENT_CHAR_BYTES = b"\xef\xbf\xbd"


def resolve_repo_file(path_arg: str) -> tuple[Path, Path]:
    candidate = (REPO_ROOT / path_arg).resolve()
    try:
        relative = candidate.relative_to(REPO_ROOT)
    except ValueError as exc:
        raise SystemExit(f"Path is outside the repository: {path_arg}") from exc

    if not candidate.is_file():
        raise SystemExit(f"File does not exist: {relative.as_posix()}")

    relative_posix = relative.as_posix()
    relative_posix_lower = relative_posix.lower()
    is_lua_file = candidate.suffix.lower() == ".lua"
    is_exchange_file = relative_posix_lower.startswith("lua/lua/ce/databridge/exchange/")
    is_map_fixture = bool(
        re.match(r"^apps/web-app/cypress/fixtures/[^/]+/[^/]+\.json$", relative_posix_lower)
    )
    if not (is_lua_file or is_exchange_file or is_map_fixture):
        raise SystemExit(
            "Only *.lua files, files below lua/LUA/ce/databridge/exchange, and "
            "files below apps/web-app/cypress/fixtures/*/*.json are allowed: "
            f"{relative_posix}"
        )

    return candidate, relative


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Verify that a Latin1-managed file does not contain UTF-8 replacement bytes."
    )
    parser.add_argument("path", help="Path relative to the repository root.")
    args = parser.parse_args()

    file_path, relative = resolve_repo_file(args.path)
    data = file_path.read_bytes()
    if REPLACEMENT_CHAR_BYTES in data:
        raise SystemExit(f"ENCODING BROKEN: {relative.as_posix()}")

    print(f"OK: {relative.as_posix()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
