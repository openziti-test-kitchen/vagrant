#!/usr/bin/env bash
# 
# provision a single node k3s cluster

# if executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        set -euxo pipefail

        curl -sfL https://get.k3s.io \
        | sudo INSTALL_K3S_EXEC="server" bash -s - \
        --write-kubeconfig-mode 0660 \
        --write-kubeconfig-group vagrant
fi
