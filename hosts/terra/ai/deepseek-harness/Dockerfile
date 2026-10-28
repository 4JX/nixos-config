# syntax=docker/dockerfile:1.7

FROM docker.io/library/node:24-trixie-slim@sha256:8ec5d7557396cfe32d21c3f9c13072355ceab22b584578ca4bb28af31120cffe

ARG DSH_VERSION
ARG PNPM_VERSION=12.6.0

ENV DEBIAN_FRONTEND=noninteractive

# A broad, conventional Debian workstation baseline.
RUN set -eu; \
    shell_and_workflow_tools=" \
      bash-completion entr file less procps psmisc tree \
    "; \
    network_and_transfer_tools=" \
      aria2 ca-certificates curl dnsutils iproute2 iputils-ping \
      netcat-openbsd openssh-client openssl rsync socat wget \
    "; \
    source_control_tools=" \
      gh git git-lfs \
    "; \
    search_and_data_tools=" \
      fd-find jq ripgrep sqlite3 \
    "; \
    archive_and_compression_tools=" \
      brotli bzip2 lz4 p7zip-full unzip xz-utils zip zstd \
    "; \
    build_and_debug_tools=" \
      autoconf automake build-essential cmake gdb libtool lsof meson \
      ninja-build patch patchelf pkg-config strace \
    "; \
    python_tools=" \
      pipx python3 python3-dev python3-pip python3-venv \
    "; \
    automation_and_quality_tools=" \
      hyperfine just parallel shellcheck shfmt \
    "; \
    media_and_document_tools=" \
      chromium ffmpeg fonts-liberation fonts-noto-cjk graphviz imagemagick \
      libimage-exiftool-perl librsvg2-bin pandoc poppler-utils tesseract-ocr \
    "; \
    apt-get update; \
    apt-get install --yes --no-install-recommends \
      $shell_and_workflow_tools \
      $network_and_transfer_tools \
      $source_control_tools \
      $search_and_data_tools \
      $archive_and_compression_tools \
      $build_and_debug_tools \
      $python_tools \
      $automation_and_quality_tools \
      $media_and_document_tools; \
    rm -rf /var/lib/apt/lists/*; \
    ln -s /usr/bin/fdfind /usr/local/bin/fd; \
    mkdir -m 0755 /workspace; \
    chown node:node /workspace

# Install the harness once while building instead of downloading and executing
# it through npx on every service start.
RUN test -n "${DSH_VERSION}" \
    && npm install --global --omit=dev --no-audit --no-fund \
      --allow-scripts=@deepseek-ai/dsh-subprocess-local,koffi,node-pty,@google/genai,protobufjs \
      "@deepseek-ai/dsh@${DSH_VERSION}" \
      "pnpm@${PNPM_VERSION}" \
    && test "$(dsh --version)" = "${DSH_VERSION}" \
    && test "$(pnpm --version)" = "${PNPM_VERSION}" \
    && npm cache clean --force

USER node
ENV HOME=/home/node \
    USER=node

ENV DSH_TELEMETRY_DISABLED=1 \
    CHROME_BIN=/usr/bin/chromium \
    CHROME_PATH=/usr/bin/chromium \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

WORKDIR /workspace
CMD ["dsh", "web", "--no-open"]
