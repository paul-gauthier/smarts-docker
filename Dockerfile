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


WORKDIR /work

ENTRYPOINT ["/opt/SMARTS_295_Linux/smarts295bat"]
