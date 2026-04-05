#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="${IMAGE_NAME:-smarts295:local}"
PLATFORM="${PLATFORM:-linux/amd64}"
VENDOR_DIR="$SCRIPT_DIR/vendor"
VENDORED_TAR="$VENDOR_DIR/smarts-295-linux-tar"

if (($# > 1)); then
    echo "usage: $0 [smarts-295-linux-tar|smarts-295-linux-tar.gz]" >&2
    exit 1
fi

if [[ ! -f "$VENDORED_TAR" ]]; then
    SOURCE_TAR="${1:-}"

    if [[ -z "$SOURCE_TAR" ]]; then
        if [[ -f "$PWD/smarts-295-linux-tar" ]]; then
            SOURCE_TAR="$PWD/smarts-295-linux-tar"
        elif [[ -f "$PWD/smarts-295-linux-tar.gz" ]]; then
            SOURCE_TAR="$PWD/smarts-295-linux-tar.gz"
        else
            echo "error: could not find smarts-295-linux-tar or smarts-295-linux-tar.gz in $PWD" >&2
            echo "download the SMARTS archive manually after accepting the license, then place it in the current working directory or pass its path as an argument" >&2
            exit 1
        fi
    fi

    if [[ ! -f "$SOURCE_TAR" ]]; then
        echo "error: file not found: $SOURCE_TAR" >&2
        exit 1
    fi

    mkdir -p "$VENDOR_DIR"

    case "$SOURCE_TAR" in
        *.gz)
            gzip -dc "$SOURCE_TAR" > "$VENDORED_TAR"
            ;;
        *)
            cp "$SOURCE_TAR" "$VENDORED_TAR"
            ;;
    esac
fi

tar -tf "$VENDORED_TAR" >/dev/null

exec docker build --platform "$PLATFORM" -t "$IMAGE_NAME" "$SCRIPT_DIR"
