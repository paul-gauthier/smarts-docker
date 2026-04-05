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

RUN LIBG2C_DEB="$(curl -fsSL http://old-releases.ubuntu.com/ubuntu/pool/universe/g/gcc-3.4/ | grep -oE 'libg2c0_[^"]+_i386\.deb' | sort -uV | tail -n 1)" \
    && [ -n "$LIBG2C_DEB" ] \
    && curl -fsSL "http://old-releases.ubuntu.com/ubuntu/pool/universe/g/gcc-3.4/${LIBG2C_DEB}" -o /tmp/libg2c0_i386.deb \
    && mkdir -p /tmp/libg2c-extract /usr/lib/i386-linux-gnu \
    && dpkg-deb -x /tmp/libg2c0_i386.deb /tmp/libg2c-extract \
    && cp -av /tmp/libg2c-extract/usr/lib/libg2c.so.0* /usr/lib/i386-linux-gnu/ \
    && ldconfig \
    && rm -rf /tmp/libg2c0_i386.deb /tmp/libg2c-extract

RUN curl -fsSL "https://www.nrel.gov/media/docs/libraries/grid/smarts-295-linux-tar.gz" -o /tmp/smarts-295-linux-tar.gz \
    && mkdir -p /opt \
    && tar -xzf /tmp/smarts-295-linux-tar.gz -C /opt \
    && sed -i 's/\r$//' "$SMARTS_HOME/smarts295bat" \
    && chmod +x "$SMARTS_HOME/smarts295" "$SMARTS_HOME/smarts295bat" \
    && ldd "$SMARTS_HOME/smarts295" | tee /tmp/smarts295.ldd \
    && ! grep -q "not found" /tmp/smarts295.ldd \
    && rm -f /tmp/smarts-295-linux-tar.gz /tmp/smarts295.ldd


COPY smarts-wrapper.sh /usr/local/bin/smarts-wrapper.sh
RUN chmod +x /usr/local/bin/smarts-wrapper.sh

WORKDIR /work

ENTRYPOINT ["/usr/local/bin/smarts-wrapper.sh"]
