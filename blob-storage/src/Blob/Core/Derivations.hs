module Blob.Core.Derivations where

import           Blob.Abstractions.Auth
import           Blob.Abstractions.Decode
import           Blob.Abstractions.Http
import           Blob.Core.BlobDB
import           Control.Monad.Trans

type Abstractions m = (Http m, Auth m, Decode m)

instance Http m => Http (BlobDB m) where
    mkRequest = lift . mkRequest

instance Auth m => Auth (BlobDB m) where
    auth b r = lift $ auth b r

instance Decode m => Decode (BlobDB m) where
    containers = lift . containers
    blobError  = lift . blobError
    blobs      = lift . blobs

instance MonadTrans BlobDB where
    lift = BlobDB . lift . lift
