# TODO

The only task tracker for putting the repos together. Each repo keeps its own TODO for its own work.

## Immediate Resumption Priority (Next Session)
1. **Verilator Simulation Link**:
   - Connect AbstractX C++ TLP client transport to `abstractx-fpga` RTL Verilator simulation (test `spi_fabric` for Tang Dual-SPI and `axi_fabric` for Zynq AXI4-Lite).
2. **Sensor Driver Migration (`[SPEC-DRV-01]`)**:
   - Port `BMP280` / `DPS310` barometers and `QMC5883L` compass to `abstractx::coro::Task` + `CoroutineIoEngine`.
3. **Flight Loop Coroutine Unification**:
   - Migrate `flight_engine_template.hpp` off `coroutine_task.hpp` to AbstractX `asp_coro.hpp` and remove duplicate `coroutine_task.hpp`.
4. **Radxa Cubie A5E Build Pipeline**:
   - Build out-of-tree Buildroot (`BR2_EXTERNAL=cubie-a5e/project-cubie-a5e`) with isolated PREEMPT_RT kernel for A5E.
5. **Interactive SITL Joystick**:
   - Add USB Gamepad / RC Radio Joystick polling to AbstractX Studio (`inav_plugin.py`).

## INAV on AbstractX
- [x] Delete `inav/include/asp_tlp64.hpp` and `pcie_bar_map.hpp`; use AbstractX's (completed 2026-11-08, inav pin `99d7e30`).
- [ ] Replace `inav/src/abstractx_engine/coroutine_task.hpp` with AbstractX's runtime and link `abstractx_core`:
  - [x] Link `libabstractx_core.a` into INAV SITL and host targets (`0ec0893`).
  - [x] Enforce `-fno-exceptions -fno-rtti` uniformly on SITL and test builds (`41c3f97`).
  - [x] Port first sensor driver (`ICM-42688-P`) to `[SPEC-DRV-01]` on `abstractx::coro::Task` + `CoroutineIoEngine` with TLP bridge requests (`test_icm42688p.cpp`).
  - [x] Migrate callers from `icm42688p_legacy.hpp` to new `icm42688p.hpp` and delete `icm42688p_legacy.hpp`.
  - [ ] Port remaining drivers (`BMP280`, `DPS310`, `QMC5883L`, `BMI088`, `MPU6000`, `MS4525DO`) to `[SPEC-DRV-01]`.
  - [ ] Migrate `flight_engine_template.hpp` and SITL scheduler off `coroutine_task.hpp` to `asp_coro.hpp`.
  - [ ] Delete `inav/src/abstractx_engine/coroutine_task.hpp`.
- [ ] Check whether `asp_coro.hpp`'s TLP awaiters can sit under `inav`'s `TlpChannel`. Change AbstractX only if its API lacks something.
- [ ] Compare `inav/src/target/linux_common` and its Pico code with `AbstractX/targets`; remove what duplicates them, keep routing.
- [ ] Decide SpecTrace in `inav`: tags, `Verified by`, checks with `--root inav`.
- [ ] Fix `inav`'s docs: addresses in `ARCHITECTURE.md` differ from its code; 8 kHz vs the 1 kHz decision; "100% COMPLETE" claims.

## Builds & Platforms
- [x] `sitl` preset on the real AbstractX runtime: builds and passes 100% (9/9 tests pass).
- [ ] `pico` preset: Pimoroni Pico Plus 2 W firmware. The Pico SDK must load before the top-level `project()`.
- [ ] Radxa Cubie A5E heterogeneous tri-compute platform:
  - [ ] Linux PREEMPT_RT kernel (`linux-cubie`, branch `cubie-linux-7.1`): verify `isolcpus=3 nohz_full=3 rcu_nocbs=3` boot parameters.
  - [ ] Buildroot out-of-tree (`BR2_EXTERNAL=cubie-a5e/project-cubie-a5e`, `LINUX_OVERRIDE_SRCDIR=linux-cubie`): generate AArch64 rootfs and toolchain.
  - [ ] Real-time co-processor firmware (XuanTie E906 RISC-V @ 200–400 MHz): build `inav_e906_app.elf` / `gps_imu_app` for RemoteProc deployment (`/lib/firmware/`), handling SPI1 IMU DMA, UART3 GPS, and I2C compass over shared SRAM (`0x40000000`).
  - [ ] Host flight binary: cross-compile `inav_linux_sbc` for AArch64 to run on isolated Core 3 under `SCHED_FIFO` 99 + `mlockall`.
  - [ ] Companion Gowin FPGA (Tang Nano 20K / Primer 20K): connect via 5-wire Dual-SPI + `INT_REQ` GPIO doorbell for DShot150-1200 + CRSF RX + WS2812.
- [ ] A7A kernel: it is on another branch (`a7a_remoteproc_camera_usb`). Decide how to build it.
- [ ] ESP32-P4 and HITL: check what exists.
- [ ] Connect AbstractX C++ TLP transport to `abstractx-fpga` Verilator simulation:
  - Architecture clarified: Two edge transports depending on deployment target (Tang FPGA is 5-wire Dual-SPI; QMTECH Zynq-7020 is AXI4-Lite). Both unpack to 64-byte TLPs over internal AXI-Stream into `asp_router`, driving `asp_wishbone_master` for peripheral IP blocks.
  - [x] Verified in `abstractx-fpga` pytest suite under Verilator (17/17 tests pass for both `spi_fabric` and `axi_fabric`).
  - [ ] Connect AbstractX C++ TLP client over socket/shm to Verilator simulation.

## SITL Simulation & Studio Visualizer (`[SPEC-SITL-07]`, `[SPEC-FLIGHT-10]`)
- [x] Flight testing with interactive transmitter sticks in AbstractX Studio (`inav_plugin.py`):
  - [x] Interactive on-screen gimbals: upgraded `_render_gimbals()` with mouse/touch drag interaction and spring-return centering (Pitch/Roll/Yaw) / hold (Throttle).
  - [x] Cockpit controls: Arm/Disarm switch (CH5 AUX1), Flight Mode selector (CH6 AUX2: Angle, Acro, RTH), and Quick Throttle presets (Cut 0%, Idle 10%, Hover 50%, Climb 65%, Full 100%).
  - [x] Stick injection into SITL flight engine: stream channels at 30 Hz via `MSP_SET_RAW_RC` (TCP :5760).
  - [x] SITL closed-loop flight loop: 6-DOF physics, vertical climb/altitude dynamics, rate PID, and QuadX mixer responding live to stick inputs.
  - [ ] USB Gamepad / RC Radio Joystick: poll connected USB transmitter (OpenTX/EdgeTX over USB) and map axes.
  - [ ] Interactive fault injection: GUI triggers for RC signal loss, GPS glitch/loss, motor failure, and sensor noise.

## Cleaning up & Boundary Enforcement
- [x] Remove `inav/external/AbstractX` ([SPEC-FLIGHT-04]; inav `6f2783d`, 2026-11-08).
- [ ] Scrub isolation violations (`check_isolation.py`):
  - [x] Remove hardcoded `/home/tcmichals` paths from `inav/src/flight/*.hpp` and `inav/tools/`.
  - [x] Replace absolute `file:///home/tcmichals/...` markdown links in `inav/README.md` and `inav/.agents/AGENTS.md`.
  - [x] Replace sibling relative paths (`../AbstractX`) in `inav/CLAUDE.md`, `inav/README.md`, `pio2/AGENTS.md`, and `pio2/src/pio2/trac.py`.
  - [ ] Scrub remaining doc links in `inav/docs/*.md` and `.vscode/`.
  - [ ] Enable build failure on `check_isolation.py` once violations are scrubbed.
- [ ] Remove `AbstractX/rtl/pio` ([SPEC-FLIGHT-04]).
- [ ] Retire `AbstractX/rtl` and its FPGA boards in favour of `abstractx-fpga` ([SPEC-FLIGHT-08]). A step of its own: AbstractX's specs, tests, rules and `rtl/pio` submodule refer to it. Ask the owner before deleting anything.
- [ ] Update `AbstractX/AGENTS.md` section 11 & docs: record that Wishbone is the internal FPGA peripheral interconnect driven by `asp_wishbone_master`, while external transports are Dual-SPI (Tang) and AXI (Zynq).
- [x] One register map: aligned `AbstractX/include/pcie_bar_map.hpp` offsets with `abstractx-fpga/cores/*.json` (dshot `throttle0..3` at 16..28, `sys_regs`, `pwm_decoder`, `neopixel`).
- [x] Retain `pio2` for Zynq deployment: use the micro-programmable PIO tile in the Zynq-7020 Artix-7 PL (ample LUT capacity on XC7Z020 compared to Tang 9K/20K). Small boards (RP2350) use native hardware PIO.
- [ ] Zynq boards: `AbstractX/hw/zynq7000/buildroot_external` and `QMTECH/zynq_qmtech_xc720`.
- [ ] `tools/visualizer/flight_plugin.py` (AbstractX) and `inav/tools/studio_plugin`: example or duplicate?
- [ ] Guide: how to build the flight controller, in `docs/`.
- [ ] SpecTrace verification matrix: link evidence ledger and `@verifies` annotations for `[SPEC-FLIGHT-01]` through `[SPEC-FLIGHT-08]`.
