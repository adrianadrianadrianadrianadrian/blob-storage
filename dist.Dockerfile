ARG BUILDIMAGE
FROM $BUILDIMAGE as deps

COPY blob-storage blob-storage
COPY blob-storage-io blob-storage-io

RUN cd blob-storage \
    && stack build \
    && stack sdist --tar-dir /dists

RUN cd blob-storage-io \
    && stack build \
    && stack sdist --tar-dir /dists

FROM alpine AS runtime
COPY --from=deps /dists /dists