# flight Engineering Log

## 2026-11-07: The design was already written down, and was not read

* **Category**: `process-gap`
* **What was missed**: an AI session spent a long discussion proposing and withdrawing layouts (a new API spec, moving chip drivers to `applib/`, generic pulse interfaces), and asked the owner to restate a design already in `inav/docs/ARCHITECTURE.md`.
* **Which check should have caught it**: the retrieval step of the operating loop. It was not run on `inav`, because the session stayed in AbstractX and judged `inav` from its code.
* **Fix**: `AGENTS.md` names `inav/docs/ARCHITECTURE.md` as required reading. No automatic check can test this.

## 2026-11-07: A recursive sync filled the disk quota

* **Category**: `tool-bug`
* **Symptom**: `repo sync` with `sync-s="true"` on AbstractX made it 1.8 GB and failed with `Disk quota exceeded`.
* **Cause**: `sync-s` follows nested submodules recursively, including MicroPython's.
* **Fix**: no `sync-s`; `make sitl` fetches only `third_party/etl`.

## 2026-11-07: INAV builds and passes on its own copies

* **Category**: `product-bug`
* **What**: `make sitl` and all 20 INAV unit test suites pass, which looks like INAV works on AbstractX. It does not link `abstractx_core`, and it finds its own `asp_tlp64.hpp` first (44-byte payload and no CRC, against AbstractX's 40 bytes plus CRC).
* **Which check should have caught it**: none exists. `inav`'s engineering log (2026-10-25) records these headers as replaced; only `spsc_tlp_ring.hpp` was. [SPEC-FLIGHT-05] now requires it, and the check is not written yet.

## 2026-11-07: INAV chose its AbstractX by where it was checked out

* **Category**: `product-bug`
* **Symptom**: four INAV build folders held three different AbstractX paths, some pointing at a live working copy. `-DABSTRACTX_PATH=` was overwritten by `FORCE`.
* **Which check should have caught it**: none existed. A `make sitl` guard failed on the workspace at `~/projects/flight` before the fix and passed after; the CMake build now passes the path in, so the guard is gone.
* **Fix**: `inav/CMakeLists.txt` uses `ABSTRACTX_PATH` if passed, otherwise `external/AbstractX`, and stops with an error if the headers are missing.
* **Done**: committed to `inav` `master` as `2dbd23a` and pinned.

## 2026-11-07: The matrix did not see tags in build files

* **Category**: `tool-bug`
* **Symptom**: `spectrace_matrix.py --matrix` showed requirements as SPEC-ONLY although `Makefile` and `default.xml` carried `@impl` tags.
* **Cause**: the scan covered only `CODE_EXTS`. AbstractX's own `CMakeLists.txt` tags were invisible too.
* **Fix**: in AbstractX ([SPEC-AUDIT-07]). The new test failed on the old tool and passes on the new one; AbstractX went from 28 to 24 SPEC-ONLY requirements. Change review still covers code files only.

## 2026-11-07: Replaced the Makefile with CMake presets

* **Category**: `process-gap`
* **Why**: a Makefile could only run separate builds side by side. As subdirectories, `inav` can link `abstractx_core` directly, and one compile database covers both.
* **Needed in AbstractX**: [SPEC-BUILD-04]: it builds as a subproject without its apps and tests, and its target files stopped using `CMAKE_SOURCE_DIR`.

## 2026-11-07: AbstractX's RTL and abstractx-fpga disagree

* **Category**: `process-gap`
* **What**: `abstractx-fpga` was split out with no PIO and with Wishbone, while `AbstractX/rtl` stayed all-PIO with no Wishbone, and AbstractX's rules were not changed. AbstractX does not mention `abstractx-fpga`, so a reader of its docs would build a design the Tang boards cannot hold.
* **Decision**: `abstractx-fpga` is the FPGA path ([SPEC-FLIGHT-08]).
* **Which check should have caught it**: none exists across repos. The copy check in `TODO.md` is meant to.

