# Build glue only ([SPEC-FLIGHT-03]). Runs from the workspace root through the link repo creates.
INAV_BUILD := build/inav-sitl
JOBS ?= $(shell nproc)
ROOT := $(CURDIR)
SPECTRACE := python3 -B AbstractX/tools/spectrace_matrix.py --root flight

.PHONY: status check-isolation spectrace matrix sitl clean

status:
	@repo forall -c 'printf "%-16s %s\n" $$REPO_PROJECT $$(git rev-parse --short HEAD)'

check-isolation:
	@python3 flight/tools/check_isolation.py .

# @impl [SPEC-FLIGHT-06] docs/SPECIFICATION.md: AbstractX's tools, run from its checkout, not copied.
spectrace:
	$(SPECTRACE) --check-skills
	$(SPECTRACE) --check-drift
	$(SPECTRACE) --check-verifies

matrix:
	@$(SPECTRACE) --matrix

# @impl [SPEC-FLIGHT-01] docs/SPECIFICATION.md: fail if INAV picked any other AbstractX.
# ETL only, at the commit AbstractX pins; its other submodules are for other targets.
sitl:
	git -C AbstractX submodule update --init --depth 1 third_party/etl
	cmake -S inav -B $(INAV_BUILD) -DABSTRACTX_PATH=$(ROOT)/AbstractX
	@grep -qE '^ABSTRACTX_PATH:PATH=$(ROOT)/AbstractX$$' $(INAV_BUILD)/CMakeCache.txt \
		|| { echo "ERROR: INAV did not use this workspace's AbstractX:"; grep '^ABSTRACTX_PATH' $(INAV_BUILD)/CMakeCache.txt; exit 1; }
	cmake --build $(INAV_BUILD) -j$(JOBS)

clean:
	rm -rf build
