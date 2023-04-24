ARG BUILDIMAGE
FROM $BUILDIMAGE as deps

COPY blob-storage blob-storage
COPY blob-storage-io blob-storage-io

RUN cd blob-storage \
    && stack build \
    && stack sdist --tar-dir .

RUN cd blob-storage-io \
    && stack build \
    && stack sdist --tar-dir .

FROM alpine AS runtime
COPY --from=deps /blob-storage/.stack-work/dist .
COPY --from=deps /blob-storage-io/.stack-work/dist .