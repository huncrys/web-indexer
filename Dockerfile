FROM alpine:3.24@sha256:71e9b7bae160ba167fa17414401b94cbcdaf3c32feeab9298bd794a2a0614c35

RUN --mount=type=cache,target=/var/cache/apk \
    apk add -uU ca-certificates tzdata

COPY web-indexer /usr/local/bin/web-indexer

ENTRYPOINT ["web-indexer"]
