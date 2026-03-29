#!/usr/bin/env python3
"""Latin1-safe ASCII replacement helper for Lua and exchange files."""

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


def encode_ascii(name: str, value: str) -> bytes:
    try:
        return value.encode("ascii")
    except UnicodeEncodeError as exc:
        raise SystemExit(f"{name} must be ASCII-only.") from exc


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Perform a Latin1-safe ASCII byte replacement in a repo-managed file."
    )
    parser.add_argument("--path", required=True, help="Path relative to the repository root.")
    parser.add_argument("--from", dest="from_text", required=True, help="ASCII text to replace.")
    parser.add_argument("--to", dest="to_text", required=True, help="ASCII replacement text.")
    args = parser.parse_args()

    if args.from_text == "":
        raise SystemExit("--from must not be empty.")

    file_path, relative = resolve_repo_file(args.path)
    old_bytes = encode_ascii("--from", args.from_text)
    new_bytes = encode_ascii("--to", args.to_text)

    data = file_path.read_bytes()
    if old_bytes not in data:
        raise SystemExit(f"Replacement source not found in {relative.as_posix()}.")

    updated = data.replace(old_bytes, new_bytes)
    if REPLACEMENT_CHAR_BYTES in updated:
        raise SystemExit("Replacement would introduce UTF-8 replacement characters.")

    file_path.write_bytes(updated)
    print(f"OK: updated {relative.as_posix()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
