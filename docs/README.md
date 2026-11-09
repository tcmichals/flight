# flight documentation
<!-- @impl [SPEC-FLIGHT-07] docs/SPECIFICATION.md: docs here are about putting it together; links, no copies. -->

This folder holds only what is about putting the system together ([SPEC-FLIGHT-07]). Everything else stays with its owner.
Paths below are relative to the workspace root, and each project is at the commit `default.xml` pins.

## In this repo

| Document | What it is |
| :--- | :--- |
| [GUIDE.md](GUIDE.md) | How to build the flight controller, step by step, with what has been shown so far |
| [SPECIFICATION.md](SPECIFICATION.md) | This repo's requirements |
| [verification/evidence/ledger.jsonl](verification/evidence/ledger.jsonl) | What ran, on which commit, with what result |
| [../engineering_log.md](../engineering_log.md) | Lessons that cross repos |
| [../TODO.md](../TODO.md) | Open work on putting the repos together |

A lesson about one project goes in that project's log, not here.

## In the other projects

| Topic | Document |
| :--- | :--- |
| **How flight code and AbstractX fit together: read this first** | `inav/docs/ARCHITECTURE.md` |
| Estimation and control | `inav/docs/FLIGHT_ESTIMATION_AND_CONTROL.md` |
| Chip drivers | `inav/docs/HARDWARE_DRIVERS.md` |
| SITL | `inav/docs/SITL_SIMULATOR.md` |
| Pico wiring and target | `inav/docs/PICO2W_WIRING_AND_SETUP.md`, `inav/docs/TARGET_PICO2.md` |
| Calibration and preflight | `inav/docs/CALIBRATION_SETUP_AND_PREFLIGHT_GUIDE.md` |
| First flight | `inav/docs/FIRST_FLIGHT_MAIDEN_CHECKLIST.md` |
| INAV testing and lessons | `inav/docs/TESTING_AND_VALIDATION.md`, `inav/docs/ENGINEERING_LOG.md` |
| Operating loop and rules | `AbstractX/AGENTS.md` |
| SpecTrace | `AbstractX/docs/SPECTRACE.md`, `AbstractX/docs/TOOLING.md` |
| Framework, HAL | `AbstractX/docs/DESIGN_SPECIFICATION.md`, `AbstractX/targets/SPECIFICATION.md` |
| TLP format | `AbstractX/docs/tier2_contracts/TLP_BUS_SPECIFICATION.md` |
| Examples | `AbstractX/apps/README.md` |
| AbstractX lessons | `AbstractX/engineering_log.md` |
| FPGA framework and blocks | `abstractx-fpga/docs/SPECIFICATION.md`, `abstractx-fpga/docs/ADDING_A_BLOCK.md` |
| PIO | `pio2/README.md`, `pio2/docs/SPECIFICATION.md` |
| Linux, Buildroot, kernel | `cubie-a5e/README.md`, `cubie-a5e/docs/README.md` (Linux group only) |

Status claims in those documents belong to those projects. Treat one as true only with evidence: `inav/TODO.md` marks phases "100% COMPLETE" while its hardware verification is still open.
