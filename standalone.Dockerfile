# syntax=docker/dockerfile:1

FROM --platform=${BUILDPLATFORM} tonistiigi/xx:1.9.0@sha256:c64defb9ed5a91eacb37f96ccc3d4cd72521c4bd18d5442905b95e2226b0e707 AS xx

FROM --platform=${BUILDPLATFORM} golang:1.26-alpine@sha256:f85330846cde1e57ca9ec309382da3b8e6ae3ab943d2739500e08c86393a21b1 AS builder

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

RUN --mount=type=cache,target=/var/cache/apk \
  apk add -uU git

ENV CGO_ENABLED=0

WORKDIR /src

COPY go.mod go.sum /src/
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go mod download

COPY --from=xx / /
ARG TARGETARCH
ARG TARGETPLATFORM
ARG BUILD_VERSION
COPY . /src/
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
<<EOT
  if [ -z "${BUILD_VERSION:-}" ]; then
    if git describe --tags --exact-match >/dev/null 2>&1; then
      BUILD_VERSION=$(git describe --tags --exact-match)
    else
      latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo 0.0.0)
      short_sha=$(git rev-parse --short HEAD 2>/dev/null || echo unknown)
      BUILD_VERSION="${latest_tag}-SNAPSHOT-${short_sha}"
    fi
    
    echo "Building version: ${BUILD_VERSION}"
  fi

  mkdir -p /rootfs/usr/local/bin

  xx-go build \
    -trimpath \
    -ldflags "-s -w -X main.version=${BUILD_VERSION}" \
    -o /rootfs/usr/local/bin/web-indexer .
EOT

FROM alpine:3.23@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11

RUN --mount=type=cache,target=/var/cache/apk \
  apk add -uU \
    ca-certificates \
    tzdata \
  ;
COPY --from=builder /rootfs/ /

ENTRYPOINT ["web-indexer"]
