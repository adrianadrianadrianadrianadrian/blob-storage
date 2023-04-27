module Blob.Core.Derivations where

import           Blob.Abstractions.Auth
import           Blob.Abstractions.Decode
import           Blob.Abstractions.Http
import           Blob.Core.BlobStorageT
import           Control.Monad.Trans

type Abstractions m = (Http m, Auth m, Decode m)

instance Http m => Http (BlobStorageT m) where
    mkRequest = lift . mkRequest

instance Auth m => Auth (BlobStorageT m) where
    auth b r = lift $ auth b r

instance Decode m => Decode (BlobStorageT m) where
    containers  = lift . containers
    blobError   = lift . blobError
    blobs       = lift . blobs
    blobContent = lift . blobContent

instance MonadTrans BlobStorageT where
    lift = BlobStorageT . lift . lift

withIO :: IO a -> BlobStorageT IO a
withIO = lift
