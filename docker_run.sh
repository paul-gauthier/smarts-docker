#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-smarts295:local}"
PLATFORM="${PLATFORM:-linux/amd64}"

docker_args=(
  --rm
  --platform "$PLATFORM"
  --user "$(id -u):$(id -g)"
  -v "$PWD:/work"
  -w /work
)

if [ -t 0 ] && [ -t 1 ]; then
  docker_args=(-it "${docker_args[@]}")
else
  docker_args=(-i "${docker_args[@]}")
fi

exec docker run "${docker_args[@]}" "$IMAGE_NAME" "$@"
