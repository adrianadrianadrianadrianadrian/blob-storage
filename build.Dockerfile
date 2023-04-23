FROM haskell:8.10.7

COPY . . 

RUN cd blob-storage \
    && stack build \ 
    && stack sdist --tar-dir .

RUN cd blob-storage-io \
    && stack build \
    && stack sdist --tar-dir .