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
