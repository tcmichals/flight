# Instructions for AI assistants

This repo follows AbstractX's project rules and SpecTrace. In a workspace, read these first:

1. [docs/SPECIFICATION.md](docs/SPECIFICATION.md): this repo's requirements.
2. `../AbstractX/AGENTS.md`, section 0: the operating loop. Sections 9 and 10: review and verification gates.
3. `../AbstractX/docs/SPECTRACE.md`: requirements, skills, evidence.
4. `../inav/docs/ARCHITECTURE.md`, before any discussion of how flight code and AbstractX fit together. It is already written down; do not ask the owner to restate it.

Each project has its own `AGENTS.md` or `CLAUDE.md`: follow it when working in that project. `inav` forbids commits unless the owner asks.

- Only this repo knows the other repos exist ([SPEC-FLIGHT-01]). Never add a sibling path to a project.
- Move a pin only with evidence in the commit message ([SPEC-FLIGHT-02]).
- No product code here ([SPEC-FLIGHT-03]). One owner per block, no copies ([SPEC-FLIGHT-05]).
- These projects follow AbstractX's SpecTrace ([SPEC-FLIGHT-12]): `flight`, `AbstractX`, `pio2`, `abstractx-fpga`, `abstractx-pico2-offload`, and any new one unless the owner exempts it. `inav`, `cubie-a5e`, `buildroot` and `linux-cubie` are exempt. In any of them: spec first, `Verified by` names a real skill, tags in code and tests, lessons in its `engineering_log.md`. A new repo starts with `AGENTS.md`, `docs/SPECIFICATION.md` and `engineering_log.md` on its first commit.
- Spec first. Tag code with `@impl [SPEC-*] <spec file>` and tests with `@verifies`. Run `cmake --build build/sitl --target flight-spectrace` from the workspace root.
- Skills in `.agents/skills/` are links to AbstractX's ([SPEC-FLIGHT-06]). Their commands run from the `AbstractX/` checkout.
- Lessons go in `engineering_log.md` with a category: `product-bug`, `tool-bug`, `false-alarm`, `process-gap` or `hardware-fact`.
- Never claim something works without running it, and end every report with what was not checked.
- Commits use `Tim Michals <tcmichals@gmail.com>` and carry no `Co-Authored-By` or other AI trailers.
