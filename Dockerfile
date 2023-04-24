ARG BUILDIMAGE
FROM $BUILDIMAGE as deps

COPY blob-storage blob-storage
COPY blob-storage-io blob-storage-io

RUN cd blob-storage \
    && stack build

RUN cd blob-storage-io \
    && stack build