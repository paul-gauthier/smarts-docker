#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="${IMAGE_NAME:-smarts295:local}"
PLATFORM="${PLATFORM:-linux/amd64}"

exec docker build --platform "$PLATFORM" -t "$IMAGE_NAME" "$SCRIPT_DIR"
