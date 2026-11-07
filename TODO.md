# TODO

The only task tracker for putting the repos together. Each repo keeps its own TODO for its own work.

- [ ] `inav/CMakeLists.txt`: use `ABSTRACTX_PATH` if passed in, otherwise fail; remove the `../` search and `FORCE`. A workspace at `~/projects/flight-stack` otherwise picks `~/projects/AbstractX`.
- [ ] `make sitl`: INAV SITL builds against the pinned AbstractX.
- [ ] `make pico`: Pico Plus 2 W firmware.
- [ ] `make linux-a5e`: Buildroot image with `BR2_EXTERNAL` and `LINUX_OVERRIDE_SRCDIR` from this workspace.
- [ ] A7A kernel: it is on another branch (`a7a_remoteproc_camera_usb`). Decide how this repo builds it.
- [ ] Test: AbstractX C++ talks to the abstractx-fpga RTL under Verilator (interfaces differ on paper: AXI4-Lite vs Wishbone).
- [ ] Remove sibling references from each repo (`make check-isolation`), then make the check fail the build.
- [ ] Remove `inav/external/AbstractX` and `AbstractX/rtl/pio` ([SPEC-STACK-04]). Check the local edits in the old `inav` checkout first.
- [ ] Decide which repo owns RTL present in both AbstractX and abstractx-fpga.
- [ ] Guide: how to build the flight controller, in `docs/`.
