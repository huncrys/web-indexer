# syntax=docker/dockerfile:1

FROM --platform=${BUILDPLATFORM} tonistiigi/xx:1.9.0@sha256:c64defb9ed5a91eacb37f96ccc3d4cd72521c4bd18d5442905b95e2226b0e707 AS xx

FROM --platform=${BUILDPLATFORM} golang:1.25-alpine@sha256:e6898559d553d81b245eb8eadafcb3ca38ef320a9e26674df59d4f07a4fd0b07 AS builder

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

FROM alpine:3.23@sha256:865b95f46d98cf867a156fe4a135ad3fe50d2056aa3f25ed31662dff6da4eb62

RUN --mount=type=cache,target=/var/cache/apk \
  apk add -uU \
    ca-certificates \
    tzdata \
  ;
COPY --from=builder /rootfs/ /

ENTRYPOINT ["docker-entrypoint"]
