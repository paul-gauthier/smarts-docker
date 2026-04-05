#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-smarts295:local}"
PLATFORM="${PLATFORM:-linux/amd64}"
CONTAINER_MOUNT_PATH=/work
CONTAINER_SMARTS_HOME=/opt/SMARTS_295_Linux

docker_args=(
  --rm
  --ulimit core=0
  --platform "$PLATFORM"
  --user "$(id -u):$(id -g)"
  -v "$PWD:$CONTAINER_MOUNT_PATH"
  -w "$CONTAINER_SMARTS_HOME"
)

if [ -t 0 ] && [ -t 1 ]; then
  docker_args=(-it "${docker_args[@]}")
else
  docker_args=(-i "${docker_args[@]}")
fi

#docker_args=(--entrypoint /bin/bash "${docker_args[@]}")

container_args=("$@")
if [ "${#container_args[@]}" -gt 0 ]; then
  if [[ "${container_args[0]}" == "$PWD"/* ]]; then
    container_args[0]="$CONTAINER_MOUNT_PATH/${container_args[0]#"$PWD"/}"
  elif [[ "${container_args[0]}" != /* ]]; then
    container_args[0]="$CONTAINER_MOUNT_PATH/${container_args[0]}"
  fi
fi

exec docker run "${docker_args[@]}" "$IMAGE_NAME" "${container_args[@]}"
