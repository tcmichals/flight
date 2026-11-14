# How to build the flight controller

An outline. A step counts as shown only with a record in [the evidence ledger](verification/evidence/ledger.jsonl), and each step states what has actually run.

## The design

Written up in `inav/docs/ARCHITECTURE.md`: flight code and chip drivers (`inav`) use `co_await` on AbstractX's 64-byte TLP bus. DShot and RC are IP blocks reached by TLP. The target and transport below handle the rest, so moving to another target changes no flight code.

## Decisions for the first aircraft

* **Board**: Pimoroni Pico Plus 2 W (RP2350B, 16 MB flash, 8 MB PSRAM). Builds still use `PICO_BOARD=pico2_w`.
* **Loop**: 1 kHz IMU and control loop, on the ground and in flight. `inav`'s docs and code still describe 8 kHz in places.
* **RC**: receiver PWM.
* **Wi-Fi**: ground setup and test only, off when armed.
* **Storage**: settings in onboard flash; flight logs to PSRAM, then flash after disarm.

## Steps

| # | Step | Status |
| :--- | :--- | :--- |
| 1 | Get the workspace | Fresh clone from GitHub run on one PC |
| 2 | Build and run SITL | Runs, but on `inav`'s own copies of AbstractX code |
| 3 | Put `inav` on the AbstractX runtime | Not started |
| 4 | Build the Pico firmware | No `flight` target yet |
| 5 | Sensors on the bench | Not shown from `flight` |
| 6 | Motors, **props off** | Not shown from `flight` |
| 7 | RC input and failsafe, **props off** | Not shown from `flight` |
| 8 | HITL | Not started |
| 9 | Calibration and preflight | Not shown from `flight` |
| 10 | First flight | Not started |

### 1. Get the workspace

Commands are in [the README](../README.md). The Linux group needs `-g default,linux`; it has not been synced in this setup.

### 2. Build and run SITL

```bash
cmake --workflow --preset sitl          # configure, build, run INAV's 5 test programs
build/sitl/inav/inav_abstractx_sitl     # Ctrl+C to stop
```

Details: `inav/docs/SITL_SIMULATOR.md`. Passing does not show `inav` works on AbstractX: the build compiles `abstractx_core` alongside it, but `inav` does not link it yet.

### 3. Put `inav` on the AbstractX runtime

Remove `inav`'s copies and use AbstractX's. The work list is in [TODO.md](../TODO.md).

### 4 to 7. Pico, sensors, motors, RC

Wiring: `inav/docs/PICO2W_WIRING_AND_SETUP.md`. Check the pins against the Pimoroni pinout, because the board differs from a Pico 2 W. Motor tests run with props off. RC loss and failsafe are tested before anything can spin up under load.

### 8. HITL

The same app on the real board, with a simulator behind some routes. What exists has not been checked.

### 9 and 10. Calibration and first flight

`inav/docs/CALIBRATION_SETUP_AND_PREFLIGHT_GUIDE.md` and `inav/docs/FIRST_FLIGHT_MAIDEN_CHECKLIST.md`. This code has never flown, and its behaviour has not been reviewed against upstream INAV here. Do not fly until steps 3 to 9 have evidence.

## Other targets

Not part of the first aircraft: A5E and A7A with Linux, each with a Pico 2 as the motor and RC I/O companion ([SPEC-FLIGHT-11]; a Tang 9K/20K can replace it on the same link); FPGA IP through `abstractx-fpga` for the Tang and Zynq boards (no PIO tile on the Tang boards); ESP32-P4.
