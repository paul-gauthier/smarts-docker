FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV SMARTS_HOME=/opt/SMARTS_295_Linux

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        libc6:i386 \
        libgcc-s1:i386 \
        libstdc++6:i386 \
        tar \
        tcsh \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://www.nrel.gov/media/docs/libraries/grid/smarts-295-linux-tar.gz" -o /tmp/smarts-295-linux-tar.gz \
    && mkdir -p /opt \
    && tar -xzf /tmp/smarts-295-linux-tar.gz -C /opt \
    && sed -i 's/\r$//' "$SMARTS_HOME/smarts295bat" \
    && chmod +x "$SMARTS_HOME/smarts295" "$SMARTS_HOME/smarts295bat" \
    && rm -f /tmp/smarts-295-linux-tar.gz

RUN cat <<'EOF' >/usr/local/bin/smarts295bat
#!/usr/bin/env bash
set -euo pipefail

run_dir="$(mktemp -d)"
install_manifest="$run_dir/.install_manifest"
work_manifest="$run_dir/.work_manifest"

cleanup() {
  rm -rf "$run_dir"
}
trap cleanup EXIT

(
  cd "$SMARTS_HOME"
  find . -mindepth 1 -print | LC_ALL=C sort
) >"$install_manifest"

if [ -d /work ]; then
  (
    cd /work
    find . -mindepth 1 \( -path './.git' -o -path './.git/*' \) -prune -o -print | LC_ALL=C sort
  ) >"$work_manifest"
else
  : >"$work_manifest"
fi

cp -a "$SMARTS_HOME"/. "$run_dir"/

if [ -d /work ]; then
  (
    cd /work
    tar --exclude=.git -cf - .
  ) | (
    cd "$run_dir"
    tar -xf -
  )
fi

should_copy_back() {
  local rel="$1"

  if [[ "$rel" == .git || "$rel" == .git/* ]]; then
    return 1
  fi

  if grep -Fxq "./$rel" "$work_manifest"; then
    if [ -e "/work/$rel" ] && [ -f "$run_dir/$rel" ] && [ -f "/work/$rel" ] && ! cmp -s "$run_dir/$rel" "/work/$rel"; then
      return 0
    fi
    return 1
  fi

  if ! grep -Fxq "./$rel" "$install_manifest"; then
    return 0
  fi

  if [ -f "$run_dir/$rel" ] && [ -f "$SMARTS_HOME/$rel" ] && ! cmp -s "$run_dir/$rel" "$SMARTS_HOME/$rel"; then
    return 0
  fi

  return 1
}

cd "$run_dir"

status=0
if ./smarts295bat "$@"; then
  status=0
else
  status=$?
fi

if [ -d /work ]; then
  while IFS= read -r relpath; do
    rel="${relpath#./}"

    if [ -d "$run_dir/$rel" ]; then
      continue
    fi

    if should_copy_back "$rel"; then
      mkdir -p "$(dirname "/work/$rel")"
      cp -a "$run_dir/$rel" "/work/$rel"
    fi
  done < <(find . -mindepth 1 -print | LC_ALL=C sort)
fi

exit "$status"
EOF

RUN chmod +x /usr/local/bin/smarts295bat

WORKDIR /work

ENTRYPOINT ["/usr/local/bin/smarts295bat"]
