FROM alpine:3.24@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6

RUN --mount=type=cache,target=/var/cache/apk \
    apk add -uU ca-certificates tzdata

COPY web-indexer /usr/local/bin/web-indexer

ENTRYPOINT ["web-indexer"]
