#!/usr/bin/env bash
# 
# provision a single node k3s cluster bound to the loopback inerface with three distinct CIDR: bind/24, cluster/16, and
# service/16.

_get_loopback(){
        # Generate a random loopback address
        local random_prefix
        random_prefix=10.$(( RANDOM % 255 + 1 ))
        echo "${random_prefix}.0.1"
}

# if executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        set -euxo pipefail

        until [[ ${ATTEMPTS:=0} -gt 9 || "$(echo -e "${LOOPBACK:-noop}\n${CLUSTER_CIDR:-noop}\n${SERVICE_CIDR:-noop}" | sort -u | wc -l)" -eq 3 ]]
        do
                LOOPBACK="$(_get_loopback)"
                CLUSTER_CIDR="$(_get_loopback)"
                SERVICE_CIDR="$(_get_loopback)"
        done
        if [[ "${ATTEMPTS}" -gt 9 ]]
        then
                echo "ERROR: failed to generate unique loopback" >&2
                exit 1
        fi

	BIND_SUBNET="${LOOPBACK}/24"
        BIND_ADDRESS="${LOOPBACK}/32"
        # Check if there is an inet address for our bind subnet on lo
        if ! ip addr show dev lo | grep -q "${BIND_SUBNET}"
        then
                sudo ip addr add "${BIND_ADDRESS}" dev lo
        fi
        # Check if there is a default IPv4 route
        if ! ip route show default | grep -q '^default'
        then
                EGRESS_INTERFACE="$(ip route show default | awk '{print $5}')"
                # Add the default IPv4 route on the egress interface
                ip route add default dev "${EGRESS_INTERFACE}"
        fi
        curl -sfL https://get.k3s.io \
        | sudo INSTALL_K3S_EXEC="server" bash -s - \
        --bind-address "${LOOPBACK}" \
        --advertise-address "${LOOPBACK}" \
        --node-ip "${LOOPBACK}" \
        --cluster-cidr "${CLUSTER_CIDR}/16" \
        --service-cidr "${SERVICE_CIDR}/16" \
        --write-kubeconfig-mode 0660 \
        --write-kubeconfig-group vagrant
fi
