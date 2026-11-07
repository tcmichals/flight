---
name: flight-isolation
runs_on: host
verifies: "Projects do not name each other by path, and every project except this repo is pinned to a commit."
description: "Check skill. Projects do not name each other by path, and every project except flight is pinned to a commit. Run when a requirement names this skill in its Verified by line or when changing default.xml or moving a pin."
---

# Skill: flight-isolation

**What it verifies**: Projects do not name each other by path ([SPEC-FLIGHT-01]), and every project except this repo is pinned to a commit ([SPEC-FLIGHT-02]).

## How to run

From the workspace root:

```bash
make check-isolation              # file count per project
python3 flight/tools/check_isolation.py . --list
make status                       # the checked-out commits
```

## Pass criteria

Report only for now: the counts must not grow. Once the existing references are removed, any reference fails.

## Evidence

The counts, in the commit message.
