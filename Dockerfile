FROM alpine:3.24@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a

RUN --mount=type=cache,target=/var/cache/apk \
    apk add -uU ca-certificates tzdata

COPY web-indexer /usr/local/bin/web-indexer

ENTRYPOINT ["web-indexer"]
