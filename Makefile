# Build glue only ([SPEC-STACK-03]). Run from the workspace root, through the symlink in the README.
INAV_BUILD := build/inav-sitl
JOBS ?= $(shell nproc)
ROOT := $(CURDIR)

.PHONY: status check-isolation sitl clean

status:
	@repo forall -c 'printf "%-16s %s\n" $$REPO_PROJECT $$(git rev-parse --short HEAD)'

check-isolation:
	@python3 .repo/manifests/tools/check_isolation.py .

# @impl [SPEC-STACK-01] docs/SPECIFICATION.md: fail if INAV picked any other AbstractX.
# ETL only, at the commit AbstractX pins; the rest of its submodules are for other targets.
sitl:
	git -C AbstractX submodule update --init --depth 1 third_party/etl
	cmake -S inav -B $(INAV_BUILD) -DABSTRACTX_PATH=$(ROOT)/AbstractX
	@grep -qE '^ABSTRACTX_PATH:PATH=$(ROOT)/(inav/\.\./)?AbstractX$$' $(INAV_BUILD)/CMakeCache.txt \
		|| { echo "ERROR: INAV did not use this workspace's AbstractX:"; grep '^ABSTRACTX_PATH' $(INAV_BUILD)/CMakeCache.txt; exit 1; }
	cmake --build $(INAV_BUILD) -j$(JOBS)

clean:
	rm -rf build
