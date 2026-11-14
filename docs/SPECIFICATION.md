# flight specification

### `[SPEC-FLIGHT-01]` Only This Repo Knows the Others
* **Requirement**: a project must not name a sibling by path or expect one at a location. This repo
  passes each dependency in: `ABSTRACTX_PATH` to INAV, `BR2_EXTERNAL` and `LINUX_OVERRIDE_SRCDIR` to Buildroot.
* **Why**: the repos reached into each other through `../` paths, home-directory paths and copied
  files, so a build depended on where it was checked out (2026-11-07: four INAV build folders held three different AbstractX paths).
* **Verified by**: `flight-isolation`
* **Implementation Target**: `CMakeLists.txt`, `tools/check_isolation.py`
* **Not implemented yet**: `tools/check_isolation.py` only reports. It fails the build once the existing references are removed. `BR2_EXTERNAL` and `LINUX_OVERRIDE_SRCDIR` have no build target yet.

### `[SPEC-FLIGHT-02]` The Manifest Pins Are the Tested Set
* **Requirement**: `default.xml` pins every project to a commit, never a branch, and the commit must be on
  its remote. The one exception is this repo, which holds the pins and follows `main`. Move a pin only after the builds and
  tests for that change pass, and record the command and its result in the commit message.
  AbstractX is pinned to a commit on its `main` (it is generic code; nothing for flight lives on a side branch of it).
* **Why**: no single repo can show that its version works with the others.
* **Verified by**: `flight-isolation`
* **Implementation Target**: `default.xml`

### `[SPEC-FLIGHT-03]` No Product Code Here
* **Requirement**: this repo holds the manifest, build glue, cross-repo tests and the guide. The Buildroot
  out-of-tree stays in `cubie-a5e/project-cubie-a5e`. `CMakeLists.txt` adds the projects as subdirectories, one CMake preset per target; the workspace root links to it.
  When two projects clash at build time, the glue sets the other project's generic switch (for INAV, which keeps
  its own `abstractx::Task` engine: `ABSTRACTX_NO_TASK_ALIASES`, AbstractX `[SPEC-ARCH-17]`); no project tests another's names.
* **Why**: otherwise this becomes one more place where the same thing lives.
* **Verified by**: `spec-change-review`
* **Implementation Target**: `CMakeLists.txt`

### `[SPEC-FLIGHT-04]` Manifest, Not Submodules, Between Projects
* **Requirement**: projects are tied together only by `default.xml`. A project keeps submodules only for
  third-party code of its own, and must not hold another project in this manifest as a submodule.
* **Why**: decided 2026-11-07. Side-by-side checkouts avoid nested copies, and a Linux group keeps the large kernel out of a flight-only checkout.
* **Verified by**: `flight-isolation`
* **Implementation Target**: `default.xml`
* **Implemented** (2026-11-08): `inav/external/AbstractX` is removed (inav `6f2783d`); INAV takes AbstractX from this workspace through `ABSTRACTX_PATH`.
* **Not implemented yet**: `AbstractX/rtl/pio` still breaks this (`TODO.md`).

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
* **Implementation Target**: `CMakeLists.txt`

### `[SPEC-FLIGHT-07]` Docs Here Are About Putting It Together
* **Requirement**: `docs/` holds the index, the guide and cross-repo evidence. Documents that belong to a project stay in that project and are linked, never copied.
  `engineering_log.md` holds lessons that cross repos, in AbstractX's format and categories; a lesson about one project goes in that project's log.
  A guide step counts as shown only with a record in `docs/verification/evidence/ledger.jsonl`.
* **Why**: decided 2026-11-07. Copied docs drift as copied code does.
* **Verified by**: `spec-change-review`
* **Implementation Target**: `docs/README.md`, `docs/GUIDE.md`

### `[SPEC-FLIGHT-08]` abstractx-fpga Is the FPGA Path; Small Boards Carry No PIO Tile
* **Requirement**: `abstractx-fpga` is the single source of truth for FPGA RTL, IP blocks and their register maps.
  * Transports differ by target: Tang Nano 9K/20K uses 5-wire Dual-SPI (`asp_spi_frontend`); QMTECH Zynq-7020 uses AXI4-Lite (`asp_axi_lite_bridge`).
  * The SBC boards (Cubie A5E, Cubie A7A) use a Pico 2 as their I/O companion first; a Tang board on the same link stays an option ([SPEC-FLIGHT-11]).
  * Both transports unpack into standard 64-byte TLPs over internal AXI-Stream into `asp_router`, driving `asp_wishbone_master` to access custom IP sockets (sys_regs, IMU DMA, DShot, PWM, UART, NeoPixel).
  * Small boards carry no PIO tile. On the RP2350, DShot and RC use `pio2` programs on the chip's own PIO. `inav` issues the same TLPs either way.
* **Why**: owner's decision, 2026-11-07, confirmed 2026-11-08. Measured in `abstractx-fpga` [SPEC-FAB-02]: the whole custom design is 3,202 logic cells on the 9K; a PIO tile alone is 11,436 at 8 pins (does not fit the 9K) and 13,071 at 16 pins on the 20K.
* **Verified by**: `flight-isolation`
* **Implementation Target**: `default.xml`
* **Not implemented yet**: `AbstractX/rtl` and `AbstractX/hw` still hold an all-PIO design, and AbstractX's rules and specs ([SPEC-ZYNQ-07], `AGENTS.md` section 11) still describe it (`TODO.md`). The PIO tile on Zynq is undecided.

### `[SPEC-FLIGHT-09]` Radxa Cubie A5E Heterogeneous Compute Architecture
* **Requirement**: The Radxa Cubie A5E (Allwinner A527/T527 octa-core Cortex-A55 + XuanTie E906 RISC-V co-processor) is the primary SBC flight platform.
  * **Under evaluation (2026-11-13)**: a Cubie A7Z is to be tried as the SBC target, because the A5E's T527 runs too hot; a heat sink for the A5E is being worked out. Until decided, the A5E text below stands.
  * **Under evaluation (2026-11-13)**: a Raspberry Pi Zero 2 W as the SBC. It has no co-processor: Linux on the Pi reads the IMU (SPI), I2C and serial and runs the flight code, and also encodes video to the SD card. The Pico 2 companion ([SPEC-FLIGHT-11]) does DShot, LEDs and RC decode. Precedent (owner): ArduPilot ran on a Pi Zero with the PXFmini.
  * **Compute Partitioning**:
    1. **PREEMPT_RT Linux Host (Cortex-A55)**:
       - Runs `inav_linux_sbc` on isolated CPU core 3 (`isolcpus=3 nohz_full=3 rcu_nocbs=3`, `SCHED_FIFO 99` + `mlockall`).
       - Executes high-level EKF3 sensor fusion, Mahony AHRS, cascading PID loops, and autonomous navigation.
       - Runs MSP Server (TCP port 5760) and Blackbox logging on non-realtime cores 0..2.
    2. **XuanTie E906 RISC-V Co-processor**:
       - Runs freestanding C++20 bare-metal I/O firmware (`inav_e906_app.elf`, RV32IMAFC, 0 B dynamic heap).
       - Direct hardware bus mastering: SPI1 (ICM-42688-P IMU at 1 kHz burst / 8 kHz rate), TWI1 (compass at 100 Hz), UART3 (u-blox NEO-M8N GPS at 115200 baud).
       - Inter-core communication: VirtIO RPMsg `/dev/rpmsg0` exchanging fixed 64-byte `Tlp64` datagrams with sub-microsecond latency.
    3. **Companion Pico 2 (RP2350)** ([SPEC-FLIGHT-11]; replaced the Gowin FPGA companion on 2026-11-13):
       - Connected to the Cubie A5E 40-pin header; the link is set by [SPEC-FLIGHT-11].
       - DShot, ESC serial passthrough, NeoPixel and 6-channel RC PWM decode on the RP2350's own PIO, using `pio2` programs.
  * **Build & Distribution Plan**:
    - Kernel: Linux 6.6-LTS PREEMPT_RT (`linux-cubie`, branch `cubie-linux-7.1`).
    - Userspace: Minimal Buildroot rootfs (`cubie-a5e/project-cubie-a5e`), compiling `inav_linux_sbc` via CMake out-of-tree (`BR2_EXTERNAL`).
    - E906 Firmware: Compiled with `riscv64-unknown-elf-gcc -march=rv32imafc -mabi=ilp32f`.
* **Why**: Eliminates Linux OS scheduling jitter from critical kHz I/O loops; achieves deterministic microsecond motor/sensor timing while providing Linux networking, Wi-Fi 6, USB telemetry, and high-compute navigation.
* **Verified by**: `spec-change-review`
* **Implementation Target**: `inav/docs/ARCHITECTURE.md`, `AbstractX/docs/tier3_targets/bsp/E906_COPROCESSOR_ARCHITECTURE.md`

### `[SPEC-FLIGHT-10]` Interactive SITL Stick Flight Simulation
* **Requirement**: The SITL simulation platform (`inav_abstractx_sitl`) must close the loop with AbstractX Studio (`inav_plugin.py`), providing complete interactive flight control without physical hardware:
  * **Interactive Gimbals**: Dual stick transmitter gimbals in Studio with click-and-drag mouse control, spring-return to center for Roll, Pitch, and Yaw, and friction position hold for Throttle.
  * **RC Stick Streaming**: Transmits 16-channel RC pulse widths (1000..2000 µs) at 30–50 Hz via `MSP_SET_RAW_RC` (command 200) over TCP :5760 to the flight controller.
  * **Arming & Mode Control**: Dedicated ARM/DISARM switch (AUX1 / Channel 5) and Flight Mode switch (AUX2 / Channel 6: Angle, Acro, RTH).
  * **6-DOF Closed-Loop Response**: SITL physics and EKF3 respond in real time to throttle and stick demands, driving 3D vector model animation, EFIS Primary Flight Display (PFD) speed/altitude tapes, and simulated motor outputs.
* **Why**: Allows proving the entire flight stack end-to-end (sensor parsing, EKF3, PID control, QuadX mixer, physics simulation, telemetry, and ground control UI) without cutting silicon, wiring boards, or risking physical airframes.
* **Verified by**: `host-tests` (`SitlLinkPluginTest` in `inav`)
* **Implementation Target**: `inav/src/target/sitl/sitl_main.cpp`, `inav/tools/studio_plugin/inav_plugin.py`

### `[SPEC-FLIGHT-11]` The SBC I/O Companion Is a Pico 2 First
* **Requirement**: on the Radxa Cubie A5E ([SPEC-FLIGHT-09]), Cubie A7A, Cubie A7Z and Raspberry Pi Zero 2 W, the motor and RC I/O companion is a Pico 2 or Pico 2 W (RP2350). Wi-Fi is not used.
  * It does four jobs, on the RP2350's own PIO from `pio2` programs, as on the Pico flight target ([SPEC-FLIGHT-08]):
    1. DShot motor outputs.
    2. ESC serial passthrough on the same motor pins, for ESC configuration and firmware update; only while disarmed.
    3. NeoPixel status LEDs.
    4. Six channels of RC receiver PWM decode.
  * The link is the 5-wire Dual-SPI link with the `INT_REQ` doorbell (SCLK, CS_N, IO0, IO1, INT_REQ), with the RP2350 as SPI target on PIO. From a Pi Zero 2 W it is plain SPI (MOSI, MISO, one bit per clock) with the same wires, exchange and `INT_REQ` (owner, 2026-11-13).
  * The SBC sends the same 64-byte TLPs it would send an FPGA, so `inav` code above the transport does not change.
  * The companion firmware is its own project, `abstractx-pico2-offload`, built on AbstractX's RP2350 target (`AbstractX/targets/pico2w_rp2350`) and `pio2` programs. Working Pico code in `rt-fc-offloader` (ESC passthrough, 4-way, MSP) moves there; it is not copied ([SPEC-FLIGHT-05]).
  * Link behaviour agreed 2026-11-13, to move to the link's owner once one is named:
    1. A combined exchange: command byte, 64-byte request TLP (host drives), 2 dummy bytes clocked one bit at a time with IO0 and IO1 released, then a 64-byte reply TLP (companion drives).
    2. The reply is staged by DMA before CS falls: the answer to an earlier request, or the latest snapshot (RC PWM values, status). No CPU work happens inside a transaction.
    3. During the command byte the companion drives a status byte on IO1: replies queued and flags (serial data, reply ready, fault).
    4. `INT_REQ` is a level, high while anything is queued. It is not raised for each PWM edge; the flight loop reads PWM from every reply.
    5. TLP channels separate registers, serial and events; tags match replies to requests.
    6. ESC serial is buffered both ways; the status reports bytes waiting and free space.
    7. The companion stops the motors (DShot 0) and refuses passthrough when no exchange with a good CRC arrives within a timeout.
  * A Tang Nano 9K or 20K running `abstractx-fpga` stays a supported companion behind the same link and TLPs; it is not the first one built.
* **Why**: owner's decision, 2026-11-13: faster to start and cheaper. The RP2350 runs `pio2` programs natively, so there is no synthesis step, and the board is already on the bench (a Pico 2 W, the same one used for IMU testing).
* **Verified by**: `spec-change-review`
* **Implementation Target**: `default.xml` (once `abstractx-pico2-offload` exists)
* **Not implemented yet**: `abstractx-pico2-offload` does not exist. The link has no owner (AbstractX's `TLP_BUS_SPECIFICATION.md` is the likely one). `abstractx-fpga`'s `asp_spi_frontend` has no exchange command, no dummy bytes and no IO1 status. The link watchdog timeout is not chosen. `inav/docs/ARCHITECTURE.md` still describes a Gowin companion. Nothing has run on hardware.

### `[SPEC-FLIGHT-12]` Every Project Follows AbstractX's SpecTrace
* **Requirement**: these projects follow AbstractX's SpecTrace, run from the `AbstractX/` checkout with `--root <project>`:
  `flight`, `AbstractX`, `pio2`, `abstractx-fpga` and `abstractx-pico2-offload`, and any new project unless the owner exempts it.
  That means requirements in `*SPECIFICATION.md` with `Verified by` lines naming real skills, `@impl` and `@verifies` tags, and an `engineering_log.md` with AbstractX's categories.
  A new project starts this way on its first commit.
  Exempt: `inav` and `cubie-a5e` (owner's decisions, 2026-11-13) and the upstream checkouts `buildroot` and `linux-cubie`.
* **Why**: owner's decision, 2026-11-13. One process across the repos, so evidence and lessons are found in the same place in each.
* **Verified by**: `spec-change-review`
* **Implementation Target**: `CMakeLists.txt`
* **Not implemented yet**: no workspace target runs the SpecTrace checks with `--root` for each project. Measured 2026-11-13 at the pinned commits with AbstractX `12e7800`:
  * `pio2`: drift in 23 requirements, 2 unbacked `@verifies`, 0 BROKEN.
  * `abstractx-fpga`: drift in 1 requirement, 3 unbacked `@verifies`, 2 BROKEN (`[SPEC-TN20K-01]`, `[SPEC-TN20K-02]` name `fpga-build`, which it has no skill for).
