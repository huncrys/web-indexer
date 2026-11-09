FROM alpine:3.24@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf

RUN --mount=type=cache,target=/var/cache/apk \
    apk add -uU ca-certificates tzdata

COPY web-indexer /usr/local/bin/web-indexer

ENTRYPOINT ["web-indexer"]
