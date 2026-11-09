#!/usr/bin/env python3
"""Report project files that name a sibling repo by path or a home directory.

@impl [SPEC-FLIGHT-01] docs/SPECIFICATION.md
@impl [SPEC-FLIGHT-05] docs/SPECIFICATION.md: one owner per block, verify no sibling paths or copies.
Report only for now: always exits 0. Usage: check_isolation.py <workspace> [--list]
"""
import pathlib
import subprocess
import sys

PROJECTS = ["inav", "AbstractX", "abstractx-fpga", "pio2", "cubie-a5e"]
SIBLINGS = "AbstractX|cubie|cubie-a5e|pio2|abstractx-fpga|quadcopter|inav|linux-cubie|buildroot"
PATTERN = rf"\.\./(\.\./)*({SIBLINGS})\b|/home/tcmichals/|projects/({SIBLINGS})\b"
# Logs record the past.
EXCLUDES = [":!engineering_log.md", ":!**/engineering_log.md", ":!docs/ENGINEERING_LOG.md"]


def main() -> int:
    workspace = pathlib.Path(sys.argv[1])
    show_files = "--list" in sys.argv
    for name in PROJECTS:
        repo = workspace / name
        if not repo.exists():
            print(f"{name}: not checked out")
            continue
        result = subprocess.run(
            ["git", "-C", str(repo), "grep", "-lE", PATTERN, "--", ".", *EXCLUDES],
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode > 1:
            print(f"{name}: git grep failed: {result.stderr.strip()}")
            continue
        files = result.stdout.split()
        print(f"{name}: {len(files)} files")
        if show_files:
            for path in files:
                print(f"  {path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
