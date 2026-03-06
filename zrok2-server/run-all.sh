#!/usr/bin/env bash
#
# Run all zrok2-server Vagrant scenarios in parallel.
#
# Usage:
#   ./run-all.sh              # run all scenarios
#   ./run-all.sh ubuntu*      # run only Ubuntu scenarios
#   ./run-all.sh alma*        # run only AlmaLinux scenarios
#
# Prerequisites:
#   - Vagrant with libvirt provider
#   - Locally-built zrok2 packages (run ./build.bash in the zrok source dir)
#   - Sufficient RAM for parallel VMs (4 GB each)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Collect scenario directories from args or discover all
if (( $# )); then
    SCENARIOS=()
    for pattern in "$@"; do
        for d in "${SCRIPT_DIR}"/${pattern}/; do
            [[ -f "${d}/Vagrantfile" ]] && SCENARIOS+=("$(basename "$d")")
        done
    done
else
    SCENARIOS=()
    for d in "${SCRIPT_DIR}"/*/; do
        [[ -f "${d}/Vagrantfile" ]] && SCENARIOS+=("$(basename "$d")")
    done
fi

if (( ${#SCENARIOS[@]} == 0 )); then
    echo "No scenarios found." >&2
    exit 1
fi

echo "=== Running ${#SCENARIOS[@]} scenario(s) ==="
printf '  %s\n' "${SCENARIOS[@]}"
echo ""

PIDS=()
LOG_DIR="$(mktemp -d)"

for scenario in "${SCENARIOS[@]}"; do
    log="${LOG_DIR}/${scenario}.log"
    (
        cd "${SCRIPT_DIR}/${scenario}"
        echo "[${scenario}] Starting vagrant up..."
        vagrant up 2>&1
        echo "[${scenario}] DONE (exit code: $?)"
    ) > "${log}" 2>&1 &
    PIDS+=($!)
    echo "  Started ${scenario} (PID $!, log: ${log})"
done

echo ""
echo "=== Waiting for all scenarios ==="

PASS=()
FAIL=()
for i in "${!PIDS[@]}"; do
    scenario="${SCENARIOS[$i]}"
    if wait "${PIDS[$i]}"; then
        PASS+=("${scenario}")
        echo "  PASS: ${scenario}"
    else
        FAIL+=("${scenario}")
        echo "  FAIL: ${scenario} (see ${LOG_DIR}/${scenario}.log)"
    fi
done

echo ""
echo "=== Results ==="
echo "  Passed: ${#PASS[@]}/${#SCENARIOS[@]}"
for s in "${PASS[@]}"; do echo "    ${s}"; done
if (( ${#FAIL[@]} )); then
    echo "  Failed: ${#FAIL[@]}/${#SCENARIOS[@]}"
    for s in "${FAIL[@]}"; do echo "    ${s}"; done
    echo ""
    echo "Logs: ${LOG_DIR}/"
    exit 1
fi
