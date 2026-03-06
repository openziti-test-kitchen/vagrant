#!/usr/bin/env bash
#
# Destroy all zrok2-server Vagrant VMs.
#
# Usage:
#   ./destroy-all.sh              # destroy all
#   ./destroy-all.sh ubuntu*      # destroy only Ubuntu scenarios
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

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

for scenario in "${SCENARIOS[@]}"; do
    echo "Destroying ${scenario}..."
    (cd "${SCRIPT_DIR}/${scenario}" && vagrant destroy -f 2>/dev/null) || true
done

echo "Done."
