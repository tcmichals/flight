# flight

The one place where the flight controller is put together. It holds no product code: each repo keeps
its one job, and [`default.xml`](default.xml), a [`repo`](https://gerrit.googlesource.com/git-repo/)
manifest, records which commits work together. The projects sit side by side as plain git checkouts.

| Project | Job | Group |
| :--- | :--- | :--- |
| `flight` | This repo: manifest, build glue, cross-repo tests, the guide | default |
| `inav` | Flight code and chip drivers | default |
| `AbstractX` | API, TLP bus, runtime, HAL, targets, examples, SpecTrace | default |
| `abstractx-fpga` | FPGA IP | default |
| `pio2` | PIO | default |
| `buildroot` | Upstream Buildroot | linux |
| `linux-cubie` | The kernel | linux |
| `cubie-a5e` | Buildroot out-of-tree and Linux development | linux |

The rules are in [docs/SPECIFICATION.md](docs/SPECIFICATION.md). Project management and enforcement use AbstractX's SpecTrace, run from the `AbstractX/` checkout, not copied here.

## Use

```bash
mkdir flight-workspace && cd flight-workspace
repo init -u git@github.com:tcmichals/flight.git -b main     # add -g default,linux for Linux builds
repo sync -c

cmake --workflow --preset sitl                     # configure, build and test INAV SITL with this workspace's AbstractX

cmake --build build/sitl --target flight-status    # the checked-out commits
cmake --build build/sitl --target flight-spectrace # AbstractX's SpecTrace checks on this repo
cmake --build build/sitl --target flight-matrix    # requirement -> code -> skills
cmake --build build/sitl --target flight-isolation # which repos still refer to a sibling (report only)
```

To work on a project, `repo start <topic> <project>` puts it on a branch; `repo sync` otherwise leaves
projects on the pinned commit. To record what is checked out as new pins: `repo manifest -r`, then copy the revisions into `default.xml`.

## Status

See [TODO.md](TODO.md). The pinned commits have not yet been shown to work together.
