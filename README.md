# WIP - Azure Blob Storage

![build workflow](https://github.com/adrianadrianadrianadrianadrian/blob-storage/actions/workflows/build.yaml/badge.svg)

Operations currently supported:
- list containers
- create container
- delete container
- lease container
- list blobs
- get blob
- delete blob
- put blob (*"BlockBlob" only*)
- lease blob

Not packaged up yet, but you can use this project (for test purposes) by referencing both the core and io projects directly via git. See the example project for basic usage.