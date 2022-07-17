module Blob.Abstractions.Decode where

import           Blob.Data.Blob
import           Blob.Data.Http

class Monad m => Decode m where
    containers :: Response -> m [Container]
    blobs :: Response -> m [Blob]
    blobError :: Response -> m Error
    blobContent :: Response -> m (Maybe BlobContent)
