#!/bin/bash
set -euo pipefail
# -----------------------------
# Customer-editable CIDRs
# -----------------------------
# IPv4 Routes to ADD / ensure exist
CIDRS_ADD=(
  # Example CIDR to add:
  # "77.0.0.0/8"
)
# IPv6 Routes to ADD / ensure exist
CIDRS_IPv6=(
  # Example CIDR to add:
  # "fd00::/8"
)

IFACE="eth0"
log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }

# Seize the Gaia config lock from any other holder so this script can run
# unattended (e.g. as a CME post-deploy customer script). When the lock is
# already ours clish returns CLICMD0201 with exit 1 — tolerate that.
clish -c "lock database override" >/dev/null 2>&1 || true

# Normalize a CIDR to its network address (zero out host bits) for both v4/v6.
# 77.77.77.77/8 -> 77.0.0.0/8 ; fd00:1:2:3::5/48 -> fd00:1:2::/48
normalize_cidr() {
  python3 -c "import ipaddress,sys;print(ipaddress.ip_network(sys.argv[1],strict=False))" "$1"
}

# -----------------------------
# IPv4 gateway from kernel routing table
# -----------------------------
GATEWAY="$(ip -4 route show dev "$IFACE" | awk '/ via /{print $3; exit}')"
if [[ -z "${GATEWAY:-}" ]]; then
  echo "ERROR: No via-route found on ${IFACE}; cannot derive IPv4 gateway" >&2
  exit 1
fi
log "Derived ${IFACE} IPv4 gateway: ${GATEWAY}"

# -----------------------------
# IPv6 gateway from kernel routing table or neighbor table
# In 2-arm GWLB mode the default IPv6 route is on eth1 only, so fall back
# to the RA-discovered router in the neighbor cache for eth0.
# -----------------------------
GW_IPv6="$(ip -6 route show dev "$IFACE" | awk '/ via /{print $3; exit}')"
if [[ -z "${GW_IPv6:-}" ]]; then
  GW_IPv6="$(ip -6 neigh show dev "$IFACE" | awk '/router/{print $1; exit}')"
fi
if [[ -z "${GW_IPv6:-}" ]]; then
  echo "ERROR: Could not determine IPv6 gateway for ${IFACE}" >&2
  exit 1
fi
log "Derived ${IFACE} IPv6 gateway: ${GW_IPv6}"

# -----------------------------
# Add/update IPv4 static routes
# -----------------------------
if [[ "${#CIDRS_ADD[@]}" -gt 0 ]]; then
  log "Adding/updating IPv4 static routes: ${CIDRS_ADD[*]}"
  for cidr in "${CIDRS_ADD[@]}"; do
    norm="$(normalize_cidr "$cidr")"
    [[ "$norm" != "$cidr" ]] && log "Normalized ${cidr} -> ${norm}"
    log "set static-route ${norm} nexthop gateway address ${GATEWAY} on"
    clish -c "set static-route ${norm} nexthop gateway address ${GATEWAY} on"
  done
fi

# -----------------------------
# Add/update IPv6 static routes
# -----------------------------
if [[ "${#CIDRS_IPv6[@]}" -gt 0 ]]; then
  log "Adding/updating IPv6 static routes: ${CIDRS_IPv6[*]}"
  for cidr in "${CIDRS_IPv6[@]}"; do
    norm="$(normalize_cidr "$cidr")"
    [[ "$norm" != "$cidr" ]] && log "Normalized ${cidr} -> ${norm}"
    log "set ipv6 static-route ${norm} nexthop gateway ${GW_IPv6} interface ${IFACE} on"
    clish -c "set ipv6 static-route ${norm} nexthop gateway ${GW_IPv6} interface ${IFACE} on"
  done
fi

# -----------------------------
# Save Gaia config
# -----------------------------
log "Saving Gaia config"
clish -c "save config"
ip -4 route flush cache || true
ip -6 route flush cache || true
