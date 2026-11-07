# flight-stack

The one place where the projects below are put together. It holds no product code: each repo keeps
its one job, and [`default.xml`](default.xml), a [`repo`](https://gerrit.googlesource.com/git-repo/)
manifest, records which commits work together. The projects sit side by side as plain git checkouts.

| Project | Job | Group |
| :--- | :--- | :--- |
| `inav` | The flight code | default |
| `AbstractX` | Runtime, HAL, targets, generic drivers, examples | default |
| `abstractx-fpga` | FPGA blocks | default |
| `pio2` | PIO | default |
| `buildroot` | Upstream Buildroot | linux |
| `linux-cubie` | The kernel | linux |
| `cubie-a5e` | Board support (`BR2_EXTERNAL`) and Linux development | linux |

The rule is in [docs/SPECIFICATION.md](docs/SPECIFICATION.md): only this repo knows the others exist.

## Use

```bash
mkdir flight-stack && cd flight-stack
repo init -u <url of this repo> -b main     # add -g default,linux for Linux builds
repo sync -c
ln -s .repo/manifests/Makefile Makefile

make status            # the checked-out commits
make check-isolation   # which repos still refer to a sibling (report only)
make sitl              # INAV SITL against this workspace's AbstractX
```

To work on a project, `repo start <topic> <project>` puts it on a branch; `repo sync` otherwise leaves
projects on the pinned commit. To record what is checked out as a new set of pins: `repo manifest -r -o default.xml`.

## Status

The pinned commits have not yet been shown to work together. See [TODO.md](TODO.md).
