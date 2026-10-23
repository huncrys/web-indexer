# syntax=docker/dockerfile:1

FROM --platform=${BUILDPLATFORM} tonistiigi/xx:1.10.0@sha256:40fe21f44bb8cddf1eb1226db190d0a984118f62ee02a91b77d99448d28264a6 AS xx

FROM olcr.io/oaklab/ci-helpers:1.1.0@sha256:244511d20c57c66762226890a3c0fa7e60fbec0aa4468d850b8e7021f4f3e49d AS helpers

FROM --platform=${BUILDPLATFORM} golang:1.27-alpine@sha256:b8c9b82affbbb82a020bbcf998dad2ba9516944ac7e883524642a481a9505e9c AS builder

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
COPY --from=helpers / /usr/local/bin/
ARG TARGETARCH
ARG TARGETPLATFORM
ARG BUILD_VERSION
COPY . /src/
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
<<EOT
  BUILD_VERSION="$(git-build-version)"

  echo "Building version: ${BUILD_VERSION}"

  mkdir -p /rootfs/usr/local/bin

  xx-go build \
    -trimpath \
    -ldflags "-s -w -X main.version=${BUILD_VERSION}" \
    -o /rootfs/usr/local/bin/web-indexer .
EOT

FROM alpine:3.24@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a

RUN --mount=type=cache,target=/var/cache/apk \
  apk add -uU \
    ca-certificates \
    tzdata \
  ;
COPY --from=builder /rootfs/ /

ENTRYPOINT ["web-indexer"]
