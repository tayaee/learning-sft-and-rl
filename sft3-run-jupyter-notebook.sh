#!/usr/bin/env bash
# run-jupyter-notebook.sh
# Run Jupyter Notebook on the given port (default 8888).
# Auto-install missing jupyter packages via uv add.

set -euo pipefail

PORT="${1:-8888}"

# Run from project root (based on script location)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check uv is installed
if ! command -v uv >/dev/null 2>&1; then
  echo "Error: 'uv' not installed. See https://docs.astral.sh/uv/"
  exit 1
fi

# Required jupyter packages
REQUIRED_PKGS=(
  "jupyter"
  "notebook"
  "ipykernel"
)

# Check pyproject.toml / uv.lock for missing packages
MISSING_PKGS=()
for pkg in "${REQUIRED_PKGS[@]}"; do
  if ! uv pip show "$pkg" >/dev/null 2>&1; then
    MISSING_PKGS+=("$pkg")
  fi
done

# Add any missing packages
if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
  echo "Adding missing packages: ${MISSING_PKGS[*]}"
  uv add "${MISSING_PKGS[@]}"
fi

# Register venv as ipykernel so jupyter can see it
KERNEL_DISPLAY_NAME="Python (learning-sft-and-rl)"
KERNEL_NAME="learning-sft-and-rl"
if ! uv run jupyter kernelspec list 2>/dev/null | grep -q "$KERNEL_NAME"; then
  echo "Registering kernel: $KERNEL_NAME"
  uv run ipython kernel install --user --name="$KERNEL_NAME" --display-name="$KERNEL_DISPLAY_NAME" >/dev/null 2>&1 || true
fi

# Determine LAN-reachable hostname.
# Discover the current host's FQDN dynamically (no hardcoding).
# Order: env → hostname -f → hostname -A → hostname.
HOSTNAME="${JUPYTER_HOSTNAME:-}"
if [ -z "$HOSTNAME" ] && command -v hostname >/dev/null 2>&1; then
  HOSTNAME="$(hostname -f 2>/dev/null || hostname --fqdn 2>/dev/null || true)"
fi
# If hostname -f returned a short name (no dot), try avahi/etc. aliases
if { [ -z "$HOSTNAME" ] || [[ "$HOSTNAME" != *.* ]]; } && command -v hostname >/dev/null 2>&1; then
  ALT="$(hostname -A 2>/dev/null | awk '{print $1}' || true)"
  if [ -n "$ALT" ] && [[ "$ALT" == *.* ]]; then
    HOSTNAME="$ALT"
  fi
fi
if [ -z "$HOSTNAME" ] && command -v hostname >/dev/null 2>&1; then
  HOSTNAME="$(hostname 2>/dev/null || true)"
fi

if [ -z "$HOSTNAME" ]; then
  echo "Error: Cannot determine hostname." >&2
  exit 1
fi

# Resolve hostname to IP (verify LAN reachability).
RESOLVED_IP=""
# Prefer mDNS for .local.
if command -v avahi-resolve >/dev/null 2>&1; then
  RESOLVED_IP="$(avahi-resolve -n "$HOSTNAME" 2>/dev/null | awk '{print $2}' | head -n1 || true)"
fi
# NSS fallback (/etc/hosts, DNS).
if [ -z "$RESOLVED_IP" ] && command -v getent >/dev/null 2>&1; then
  RESOLVED_IP="$(getent hosts "$HOSTNAME" 2>/dev/null | awk '{print $1}' | head -n1 || true)"
fi

if [ -z "$RESOLVED_IP" ]; then
  echo "Error: Cannot resolve '${HOSTNAME}'." >&2
  echo "   - Check avahi-daemon is running, or" >&2
  echo "   - Add '${HOSTNAME}' to /etc/hosts or DNS." >&2
  exit 1
fi

echo "Host FQDN: ${HOSTNAME} -> ${RESOLVED_IP}"
echo "Starting Jupyter Notebook at http://${HOSTNAME}:${PORT}"
# Bind all interfaces for LAN access.
exec uv run jupyter notebook --port="$PORT" --no-browser --ip=0.0.0.0