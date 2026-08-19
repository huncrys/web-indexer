# syntax=docker/dockerfile:1

FROM --platform=${BUILDPLATFORM} tonistiigi/xx:1.9.0@sha256:c64defb9ed5a91eacb37f96ccc3d4cd72521c4bd18d5442905b95e2226b0e707 AS xx

FROM olcr.io/oaklab/ci-helpers:1.1.0@sha256:244511d20c57c66762226890a3c0fa7e60fbec0aa4468d850b8e7021f4f3e49d AS helpers

FROM --platform=${BUILDPLATFORM} golang:1.27-alpine@sha256:7d5cbf6833f7331dafd25a2e8b9673477f559759ff8ed4ca8efabe6795ad08db AS builder

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

FROM alpine:3.24@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b

RUN --mount=type=cache,target=/var/cache/apk \
  apk add -uU \
    ca-certificates \
    tzdata \
  ;
COPY --from=builder /rootfs/ /

ENTRYPOINT ["web-indexer"]
