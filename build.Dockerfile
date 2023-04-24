FROM haskell:8.10.7

COPY blob-storage blob-storage
COPY blob-storage-io blob-storage-io

RUN cd blob-storage \
    && stack build --only-dependencies
    
RUN cd blob-storage-io \
    && stack build --only-dependencies
