module Blob.Abstractions.Auth where

import           Blob.Data.Blob
import           Blob.Data.Http

class Monad m => Auth m where
    auth :: BlobContext -> Request -> m Request
