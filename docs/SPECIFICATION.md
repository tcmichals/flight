# flight specification

### `[SPEC-FLIGHT-01]` Only This Repo Knows the Others
* **Requirement**: a project must not name a sibling by path or expect one at a location. This repo
  passes each dependency in: `ABSTRACTX_PATH` to INAV, `BR2_EXTERNAL` and `LINUX_OVERRIDE_SRCDIR` to Buildroot.
* **Why**: the repos reached into each other through `../` paths, home-directory paths and copied
  files, so a build depended on where it was checked out (2026-11-07: four INAV build folders held three different AbstractX paths).
* **Verified by**: `flight-isolation`
* **Implementation Target**: `Makefile`, `tools/check_isolation.py`
* **Not implemented yet**: `tools/check_isolation.py` only reports. It fails the build once the existing references are removed. `BR2_EXTERNAL` and `LINUX_OVERRIDE_SRCDIR` have no make target yet.

### `[SPEC-FLIGHT-02]` The Manifest Pins Are the Tested Set
* **Requirement**: `default.xml` pins every project to a commit, never a branch, and the commit must be on
  its remote. The one exception is this repo, which holds the pins and follows `main`. Move a pin only after the builds and
  tests for that change pass, and record the command and its result in the commit message.
* **Why**: no single repo can show that its version works with the others.
* **Verified by**: `flight-isolation`
* **Implementation Target**: `default.xml`

### `[SPEC-FLIGHT-03]` No Product Code Here
* **Requirement**: this repo holds the manifest, build glue, cross-repo tests and the guide. The Buildroot
  out-of-tree stays in `cubie-a5e/project-cubie-a5e`.
* **Why**: otherwise this becomes one more place where the same thing lives.
* **Verified by**: `spec-change-review`
* **Implementation Target**: `Makefile`

### `[SPEC-FLIGHT-04]` Manifest, Not Submodules, Between Projects
* **Requirement**: projects are tied together only by `default.xml`. A project keeps submodules only for
  third-party code of its own, and must not hold another project in this manifest as a submodule.
* **Why**: decided 2026-11-07. Side-by-side checkouts avoid nested copies, and a Linux group keeps the large kernel out of a flight-only checkout.
* **Verified by**: `flight-isolation`
* **Implementation Target**: `default.xml`
* **Not implemented yet**: `inav/external/AbstractX` and `AbstractX/rtl/pio` break this today (`TODO.md`).

### `[SPEC-FLIGHT-05]` One Owner per Block, No Copies
* **Requirement**: each block has one owner, and every other project uses it from there:

  | Block | Owner |
  | :--- | :--- |
  | Flight code, chip drivers, routing, SITL and HITL setups | `inav` |
  | API, TLP bus, runtime, `hal/`, `IIoProcessor`, targets, transports, examples | `AbstractX` |
  | FPGA RTL and IP, and their register maps ([SPEC-FLIGHT-08]) | `abstractx-fpga` |
  | PIO | `pio2` |
  | CPU and SoC hardware facts: registers, IRQs, pins per chip | `AbstractX/targets/*/include/hal/ports.hpp` |
  | Aircraft wiring: which pin goes where on this airframe | `inav` |
  | Which versions work together | `flight` |
  | Kernel | `linux-cubie` |
  | Buildroot out-of-tree, Linux development | `cubie-a5e` |

* **Why**: `inav` holds its own TLP headers (with a different layout) and coroutine engine, and does not link `abstractx_core`. Its `docs/ARCHITECTURE.md` already describes the right design; nothing enforced it.
* **Verified by**: `flight-isolation`
* **Implementation Target**: `tools/check_isolation.py`
* **Not implemented yet**: the check does not yet look for copied files.

### `[SPEC-FLIGHT-06]` AbstractX's SpecTrace, Not a Copy
* **Requirement**: this repo uses AbstractX's rules, skills and tools from the `AbstractX/` checkout in the workspace:
  requirements in `*SPECIFICATION.md`, `@impl` and `@verifies` tags, `Verified by` lines. Tools run with `--root flight` and are never copied here.
  Skills are links to AbstractX's; only skills about this repo itself live here.
* **Why**: the owner's decision, 2026-11-07. A copy of the tools is one more thing to drift.
* **Verified by**: `spec-change-review`
* **Implementation Target**: `Makefile`

### `[SPEC-FLIGHT-07]` Docs Here Are About Putting It Together
* **Requirement**: `docs/` holds the index, the guide and cross-repo evidence. Documents that belong to a project stay in that project and are linked, never copied.
  `engineering_log.md` holds lessons that cross repos, in AbstractX's format and categories; a lesson about one project goes in that project's log.
  A guide step counts as shown only with a record in `docs/verification/evidence/ledger.jsonl`.
* **Why**: decided 2026-11-07. Copied docs drift as copied code does.
* **Verified by**: `spec-change-review`
* **Implementation Target**: `docs/README.md`, `docs/GUIDE.md`

### `[SPEC-FLIGHT-08]` abstractx-fpga Is the FPGA Path; Small Boards Carry No PIO Tile
* **Requirement**: `abstractx-fpga` is the single source of truth for FPGA RTL, IP blocks and their register maps. Tang Nano 9K and 20K
  designs use its custom blocks and carry no PIO tile. On the RP2350, DShot and RC use `pio2` programs on the chip's own PIO. `inav` issues the same TLPs either way.
* **Why**: owner's decision, 2026-11-07. Measured in `abstractx-fpga` [SPEC-FAB-02]: the whole custom design is 3,202 logic cells on the 9K; a PIO tile alone is 11,436 at 8 pins (does not fit the 9K) and 13,071 at 16 pins on the 20K.
* **Verified by**: `flight-isolation`
* **Implementation Target**: `default.xml`
* **Not implemented yet**: `AbstractX/rtl` and `AbstractX/hw` still hold an all-PIO design, and AbstractX's rules and specs ([SPEC-ZYNQ-07], `AGENTS.md` section 11) still describe it (`TODO.md`). The PIO tile on Zynq is undecided.
