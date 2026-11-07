# flight-stack specification

### `[SPEC-STACK-01]` Only This Repo Knows the Others
* **Requirement**: a project must not name a sibling by path or expect one at a location. This repo
  passes each dependency in: `ABSTRACTX_PATH` to INAV, `BR2_EXTERNAL` and `LINUX_OVERRIDE_SRCDIR` to Buildroot.
* **Why**: the repos reached into each other through `../` paths, home-directory paths and copied
  files, so a build depended on where it was checked out (2026-11-07: four INAV build folders held three different AbstractX paths).
* **Verified by**: `make check-isolation`, report only until the existing references are removed, then it fails the build.
  `make sitl` fails if INAV used any AbstractX other than this workspace's.

### `[SPEC-STACK-02]` The Manifest Pins Are the Tested Set
* **Requirement**: `default.xml` pins every project to a commit, never a branch, and the commit must be on
  its remote. Move a pin only after the builds and tests for that change pass, and record the command and its result in the commit message.
* **Why**: no single repo can show that its version works with the others.
* **Verified by**: `make status`, and the build targets the changed pin affects.

### `[SPEC-STACK-03]` No Product Code Here
* **Requirement**: this repo holds the manifest, build glue, per-board configuration, cross-repo tests and the guide.
  Flight code goes in INAV, runtime in AbstractX, RTL in abstractx-fpga or pio2, kernel and board support in linux-cubie and cubie-a5e.
* **Why**: otherwise this becomes one more place where the same thing lives.
* **Verified by**: review.

### `[SPEC-STACK-04]` Manifest, Not Submodules, Between Projects
* **Requirement**: projects are tied together only by `default.xml`. A project keeps submodules only for
  third-party code of its own, and must not hold another project in this manifest as a submodule.
* **Why**: decided 2026-11-07. Side-by-side checkouts avoid nested copies, and a Linux group keeps the large kernel out of a flight-only checkout.
* **Open**: `inav/external/AbstractX` and `AbstractX/rtl/pio` break this today (`TODO.md`).
* **Verified by**: review, until `make check-isolation` covers it.
