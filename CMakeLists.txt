# Build glue only ([SPEC-FLIGHT-03]). The workspace root links here, so projects are subdirectories.
cmake_minimum_required(VERSION 3.21)
project(flight LANGUAGES C CXX ASM)

find_package(Python3 REQUIRED COMPONENTS Interpreter)
enable_testing()

# @impl [SPEC-FLIGHT-01] docs/SPECIFICATION.md: this workspace's AbstractX, passed in, never searched for.
set(ABSTRACTX_PATH "${CMAKE_CURRENT_SOURCE_DIR}/AbstractX" CACHE PATH "AbstractX used by every project" FORCE)

# ETL only, at the commit AbstractX pins; its other submodules are for other targets.
if(NOT EXISTS "${ABSTRACTX_PATH}/third_party/etl/include/etl/memory_model.h")
    execute_process(
        COMMAND git -C "${ABSTRACTX_PATH}" submodule update --init --depth 1 third_party/etl
        COMMAND_ERROR_IS_FATAL ANY)
endif()

add_subdirectory(AbstractX)
add_subdirectory(inav)

# @impl [SPEC-FLIGHT-06] docs/SPECIFICATION.md: AbstractX's tools, run from its checkout with --root, not copied.
set(FLIGHT_SPECTRACE "${Python3_EXECUTABLE}" -B "${ABSTRACTX_PATH}/tools/spectrace_matrix.py"
    --root "${CMAKE_CURRENT_SOURCE_DIR}/flight")
add_custom_target(flight-spectrace
    COMMAND ${FLIGHT_SPECTRACE} --check-skills
    COMMAND ${FLIGHT_SPECTRACE} --check-drift
    COMMAND ${FLIGHT_SPECTRACE} --check-verifies
    VERBATIM)
add_custom_target(flight-matrix COMMAND ${FLIGHT_SPECTRACE} --matrix VERBATIM)
add_custom_target(flight-isolation
    COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/flight/tools/check_isolation.py" "${CMAKE_CURRENT_SOURCE_DIR}"
    VERBATIM)
add_custom_target(flight-status
    COMMAND repo forall -c "printf '%-16s %s\\n' $REPO_PROJECT $(git rev-parse --short HEAD)"
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    VERBATIM)
