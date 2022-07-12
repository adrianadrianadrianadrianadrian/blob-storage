module Blob.Core.Containers where

import           Blob.Abstractions.Auth
import           Blob.Abstractions.Decode
import           Blob.Abstractions.Http
import           Blob.Core.BlobDB
import           Blob.Core.Derivations
import           Blob.Core.Shared
import           Blob.Data.Blob
import           Blob.Data.Http
import           Control.Lens
import           Control.Monad.Except
import           Control.Monad.Reader
import qualified Data.Text                     as T

listContainers :: Abstractions m => BlobDB m [Container]
listContainers = do
    ctx <- ask
    req <- auth ctx $ defaultGET (blobDomain ctx)
                    & params <>~ [("comp", "list"), ("restype", "container")]
    res <- mkRequest req >>= validate
    containers res

createContainer :: Abstractions m => T.Text -> BlobDB m ()
createContainer containerName = do
    ctx <- ask
    req <- auth ctx $ defaultPUT (blobDomain ctx) mempty 
                    & params <>~ [("restype", "container")]
                    & path ?~ containerName
                    & requestHeaders <>~ [("Content-Type", "application/octet-stream")]
    mkRequest req >>= validate >> pure ()

deleteContainer :: Abstractions m => T.Text -> BlobDB m ()
deleteContainer containerName = do
    ctx <- ask
    req <- auth ctx $ defaultDELETE (blobDomain ctx) 
                    & params <>~ [("restype", "container")]
                    & path ?~ containerName
    mkRequest req >>= validate >> pure ()

leaseContainer :: Abstractions m => T.Text -> LeaseCommand -> BlobDB m (Maybe LeaseId)
leaseContainer containerName leaseCmd = do
    ctx <- ask
    req <- auth ctx $ defaultPUT (blobDomain ctx) mempty
                    & params <>~ [("restype", "container"), ("comp", "lease")]
                    & path ?~ containerName
                    & requestHeaders <>~ [ ("x-ms-lease-action", T.pack . show $ leaseCmd)
                                         , ("Content-Type", "application/octet-stream")
                                         ] <> leaseHeaders leaseCmd
    mkRequest req >>= validate <&> leaseIdFromResponse

