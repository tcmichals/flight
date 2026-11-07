# TODO

The only task tracker for putting the repos together. Each repo keeps its own TODO for its own work.

## INAV on AbstractX
- [ ] `inav/CMakeLists.txt`: use `ABSTRACTX_PATH` if passed in, otherwise `external/AbstractX`; remove the `../` search and `FORCE`.
- [ ] Delete `inav/include/asp_tlp64.hpp` and `pcie_bar_map.hpp`; use AbstractX's (their layouts differ).
- [ ] Replace `inav/src/abstractx_engine/coroutine_task.hpp` with AbstractX's runtime and link `abstractx_core`. Its pool reuses memory from the start when full (read, not tested).
- [ ] Check whether `asp_coro.hpp`'s TLP awaiters can sit under `inav`'s `TlpChannel`. Change AbstractX only if its API lacks something.
- [ ] Compare `inav/src/target/linux_common` and its Pico code with `AbstractX/targets`; remove what duplicates them, keep routing.
- [ ] Decide SpecTrace in `inav`: tags, `Verified by`, `make spectrace --root inav`.
- [ ] Fix `inav`'s docs: addresses in `ARCHITECTURE.md` differ from its code; 8 kHz vs the 1 kHz decision; "100% COMPLETE" claims.

## Builds
- [ ] `make sitl` on real AbstractX runtime.
- [ ] `make pico`: Pimoroni Pico Plus 2 W firmware.
- [ ] `make a5e`: Buildroot with `BR2_EXTERNAL=cubie-a5e/project-cubie-a5e` and `LINUX_OVERRIDE_SRCDIR` from this workspace.
- [ ] A7A kernel: it is on another branch (`a7a_remoteproc_camera_usb`). Decide how to build it.
- [ ] ESP32-P4 and HITL: check what exists.
- [ ] Test: AbstractX C++ talks to the abstractx-fpga RTL under Verilator (interfaces differ on paper: AXI4-Lite vs Wishbone).

## Tooling
- [ ] Decide: replace the Makefile with CMake presets and `add_subdirectory` (recommended, not started).
- [ ] Decide: matrix does not see `@impl` tags in `Makefile` and `default.xml`.
- [ ] Commit the `inav` CMake path fix (owner's word needed) and pin it.

## Cleaning up
- [ ] `check_isolation.py`: find copied files; remove existing references; then fail the build.
- [ ] Remove `inav/external/AbstractX` and `AbstractX/rtl/pio` ([SPEC-FLIGHT-04]). First save the local edits in `~/projects/quadcopter/inav/external/AbstractX`.
- [ ] Retire `AbstractX/rtl` and its FPGA boards in favour of `abstractx-fpga` ([SPEC-FLIGHT-08]). A step of its own: AbstractX's specs, tests, rules and `rtl/pio` submodule refer to it. Ask the owner before deleting anything.
- [ ] Fix the contradictions when that happens: [SPEC-ZYNQ-07] (100% PIO), `AbstractX/AGENTS.md` section 11 (no Wishbone; `abstractx-fpga` uses Wishbone).
- [ ] One register map: `AbstractX/include/asp_tlp64.h` and `pcie_bar_map.hpp` list different DShot addresses from `abstractx-fpga`.
- [ ] Decide whether Zynq needs the PIO tile. Not measured here.
- [ ] Zynq boards: `AbstractX/hw/zynq7000/buildroot_external` and `QMTECH/zynq_qmtech_xc720`.
- [ ] `tools/visualizer/flight_plugin.py` (AbstractX) and `inav/tools/studio_plugin`: example or duplicate?
- [ ] Guide: how to build the flight controller, in `docs/`.
