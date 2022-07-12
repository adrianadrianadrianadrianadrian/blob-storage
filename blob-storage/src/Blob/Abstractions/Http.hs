module Blob.Abstractions.Http where

import           Blob.Data.Http

class Monad m => Http m where
    mkRequest :: Request -> m Response
