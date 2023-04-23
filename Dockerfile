ARG BUILDIMAGE
FROM $BUILDIMAGE as deps

COPY . .

FROM alpine AS runtime
COPY --from=deps /blob-storage/.stack-work/dist .