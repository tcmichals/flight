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
- [ ] `pio2` on SpecTrace: drift in 23 requirements (paths to code not yet written, e.g. `tests/uvm/`, `tools/hil/`); 2 unbacked `@verifies` (`tests/test_host_frame.py`, `tests/test_trace_ctf.py`).
- [ ] `abstractx-fpga` on SpecTrace: 2 BROKEN (`[SPEC-TN20K-01]`, `[SPEC-TN20K-02]` name `fpga-build`, no such skill); drift in `[SPEC-ZYNQ-07]` (`rtl/pio/`, `asp_pio_wrap.sv`); 3 unbacked `@verifies` (`[SPEC-FPGA-CLK-01]`).
- [ ] Fix `inav`'s docs: addresses in `ARCHITECTURE.md` differ from its code; 8 kHz vs the 1 kHz decision; "100% COMPLETE" claims.

## Builds & Platforms
- [x] `sitl` preset on the real AbstractX runtime: builds and passes 100% (9/9 tests pass).
- [ ] `pico` preset: Pimoroni Pico Plus 2 W firmware. The Pico SDK must load before the top-level `project()`.
- [ ] Radxa Cubie A5E heterogeneous tri-compute platform:
  - [ ] Linux PREEMPT_RT kernel (`linux-cubie`, branch `cubie-linux-7.1`): verify `isolcpus=3 nohz_full=3 rcu_nocbs=3` boot parameters.
  - [ ] Buildroot out-of-tree (`BR2_EXTERNAL=cubie-a5e/project-cubie-a5e`, `LINUX_OVERRIDE_SRCDIR=linux-cubie`): generate AArch64 rootfs and toolchain.
  - [ ] Real-time co-processor firmware (XuanTie E906 RISC-V @ 200–400 MHz): build `inav_e906_app.elf` / `gps_imu_app` for RemoteProc deployment (`/lib/firmware/`), handling SPI1 IMU DMA, UART3 GPS, and I2C compass over shared SRAM (`0x40000000`).
  - [ ] Host flight binary: cross-compile `inav_linux_sbc` for AArch64 to run on isolated Core 3 under `SCHED_FIFO` 99 + `mlockall`.
  - [ ] Companion Pico 2 / Pico 2 W, Wi-Fi off ([SPEC-FLIGHT-11]; Tang Nano 9K/20K stays an alternative), on native PIO with `pio2` programs:
    - [ ] 5-wire Dual-SPI target on PIO with `INT_REQ` doorbell, decoding 64-byte TLPs.
    - [ ] DShot motor outputs.
    - [ ] ESC serial passthrough on the motor pins (configuration and firmware update), disarmed only.
    - [ ] NeoPixel.
    - [ ] 6-channel RC PWM decode.
    - [ ] PIO state-machine budget for all of the above on the RP2350's 12 state machines.
- [ ] A7A kernel: it is on another branch (`a7a_remoteproc_camera_usb`). Decide how to build it.
- [ ] A7A I/O companion: Pico 2, same as A5E ([SPEC-FLIGHT-11]).
- [ ] Pi Zero 2 W as the SBC ([SPEC-FLIGHT-09], 2026-11-13):
  - [ ] Check that `spi-bcm2835` has no dual mode (plain SPI to the Pico is decided either way); IMU and Pico link on separate SPI buses.
  - [ ] Video encoding to the SD card next to a 1 kHz loop: hardware encoder, on cores other than the flight core; measure loop jitter and SD write latency with recording on and off.
  - [ ] GPS on the PL011 UART (Bluetooth off); temperatures under flight load with recording.
- [ ] Try the Cubie A7Z as the SBC target ([SPEC-FLIGHT-09], 2026-11-13): the A5E's T527 runs too hot. Record board temperatures (idle, under the flight load) for both, with and without a heat sink, in `engineering_log.md`.
- [ ] Update `inav/docs/ARCHITECTURE.md` and `AbstractX/docs/tier3_targets/bsp/E906_COPROCESSOR_ARCHITECTURE.md`: the A5E companion is a Pico 2, not a Gowin FPGA.
- [ ] ESP32-P4 and HITL: check what exists.
- [ ] Connect AbstractX C++ TLP transport to `abstractx-fpga` Verilator simulation:
  - Architecture clarified: Two edge transports depending on deployment target (Tang FPGA is 5-wire Dual-SPI; QMTECH Zynq-7020 is AXI4-Lite). Both unpack to 64-byte TLPs over internal AXI-Stream into `asp_router`, driving `asp_wishbone_master` for peripheral IP blocks.
  - [x] Verified in `abstractx-fpga` pytest suite under Verilator (17/17 tests pass for both `spi_fabric` and `axi_fabric`).
  - [ ] Connect AbstractX C++ TLP client over socket/shm to Verilator simulation.

## Pico 2 I/O Companion (`[SPEC-FLIGHT-11]`)
- [x] Create `tcmichals/abstractx-pico2-offload` (public), first commit `722cc58`: spec `[SPEC-OFFLOAD-01..06]`, `AGENTS.md`, `engineering_log.md`, skills, GPL-3.0-or-later; SpecTrace checks clean.
- [ ] Add it to `default.xml`, the [SPEC-FLIGHT-05] owner table, `README.md` and `tools/check_isolation.py`.
- [ ] `abstractx-pico2-offload`: link AbstractX's Pico target with Wi-Fi off (`ABSTRACTX_PICO_WIFI=OFF`, presets `pico2w-nowifi` / `pico2`, AbstractX `001cef1` [SPEC-PICO-CFG-01]) instead of `abstractx_core` alone, and drop its `EXCLUDE_FROM_ALL` workaround.
- [ ] Move ESC passthrough, 4-way and MSP from `rt-fc-offloader/firmware` into it; mark `rt-fc-offloader`'s Pico path retired.
- [ ] Compare `rt-fc-offloader`'s `dshot.pio` and `esc_pio_uart.pio` (run on hardware) with `pio2`'s `dshot_bidir.pio` and `esc_serial.pio`; keep one copy, in `pio2`.
- [ ] Add NeoPixel and 6-channel PWM-decode programs to `pio2`.
- [ ] Name the link's owner and move the link behaviour in [SPEC-FLIGHT-11] there.
- [ ] `abstractx-fpga` `asp_spi_frontend`: add the exchange command, 2 dummy bytes and IO1 status, so a Tang stays interchangeable. Check whether it drives IO0 on the clock right after the command byte (possible contention).
- [ ] Check that the A527 SPI controller and `spi-sun6i` do dual mode and capture IO1 during the single-bit phase.
- [ ] Bench: Pico 2 W SPI target, CRC-error sweep over SCLK, scope the turnaround; record in the evidence ledger.
- [ ] Choose the link watchdog timeout.

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
- [ ] One register map: align `AbstractX/include/pcie_bar_map.hpp` offsets with `abstractx-fpga/cores/*.json` (dshot `throttle0..3` at 16..28, `sys_regs`, `pwm_decoder`, `neopixel`). Done once in AbstractX `12e7800` on `flight-integration`, not on `main`, so not in the pin since 2026-11-14. Owner to decide: take it to AbstractX `main` (its `PwmBase` 0x40000300 equals `BaroBase`), and delete `flight-integration` after.
- [x] Retain `pio2` for Zynq deployment: use the micro-programmable PIO tile in the Zynq-7020 Artix-7 PL (ample LUT capacity on XC7Z020 compared to Tang 9K/20K). Small boards (RP2350) use native hardware PIO.
- [ ] Zynq boards: `AbstractX/hw/zynq7000/buildroot_external` and `QMTECH/zynq_qmtech_xc720`.
- [ ] `tools/visualizer/flight_plugin.py` (AbstractX) and `inav/tools/studio_plugin`: example or duplicate?
- [ ] Guide: how to build the flight controller, in `docs/`.
- [ ] SpecTrace verification matrix: link evidence ledger and `@verifies` annotations for `[SPEC-FLIGHT-01]` through `[SPEC-FLIGHT-12]`.
- [ ] `flight-isolation` should check that the AbstractX pin is a commit on AbstractX `main` ([SPEC-FLIGHT-02], `engineering_log.md` 2026-11-14).
- [ ] `flight-spectrace` should fail when the matrix shows a BROKEN requirement; today no `spectrace_matrix.py` flag does that without also failing on every unverified one (`engineering_log.md`, 2026-11-13).
- [ ] Add a workspace target that runs the SpecTrace checks with `--root` for each project ([SPEC-FLIGHT-12]).
