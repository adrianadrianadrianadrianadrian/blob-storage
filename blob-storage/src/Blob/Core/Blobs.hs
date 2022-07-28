module Blob.Core.Blobs where

import           Blob.Abstractions.Auth
import           Blob.Abstractions.Decode
import           Blob.Abstractions.Http
import           Blob.Core.BlobStorageT
import           Blob.Core.Derivations
import           Blob.Core.Shared
import           Blob.Data.Blob
import           Blob.Data.Http
import           Control.Lens
import           Control.Monad.Except
import           Control.Monad.Reader
import qualified Data.ByteString               as BS
import qualified Data.Text                     as T

listBlobs :: Abstractions m => T.Text -> BlobStorageT m [Blob]
listBlobs containerName = do
    ctx <- ask
    req <- auth ctx $ defaultGET (blobDomain ctx)
                    & params <>~ [("restype", "container"), ("comp", "list")]
                    & path ?~ containerName
    res <- mkRequest req >>= validate
    blobs res

getBlob :: Abstractions m => T.Text -> T.Text -> BlobStorageT m (Maybe BlobContent)
getBlob containerName blobName = do
    ctx <- ask
    req <- auth ctx $ defaultGET (blobDomain ctx)
                    & path ?~ containerName <> "/" <> blobName
    res <- mkRequest req >>= validate
    blobContent res

deleteBlob :: Abstractions m => T.Text -> T.Text -> BlobStorageT m ()
deleteBlob containerName blobName = do
    ctx <- ask
    req <- auth ctx $ defaultDELETE (blobDomain ctx)
                    & path ?~ containerName <> "/" <> blobName
    mkRequest req >>= validate >> pure ()

putBlob :: Abstractions m => T.Text -> T.Text -> BS.ByteString -> BlobStorageT m ()
putBlob containerName blobName blobContent = do
    ctx <- ask
    req <- auth ctx $ defaultPUT (blobDomain ctx) blobContent
                    & path ?~ containerName <> "/" <> blobName
                    & requestHeaders <>~ [ ("Content-Length", T.pack . show . BS.length $ blobContent)
                                         , ("x-ms-blob-type", "BlockBlob")
                                         , ("Content-Type", inferContentType blobName)
                                         ]
    mkRequest req >>= validate >> pure ()

leaseBlob :: Abstractions m => T.Text -> T.Text -> LeaseCommand -> BlobStorageT m (Maybe LeaseId)
leaseBlob containerName blobName leaseCmd = do
    ctx <- ask
    req <- auth ctx $ defaultPUT (blobDomain ctx) mempty
                    & params <>~ [("comp", "lease")]
                    & path ?~ containerName <> "/" <> blobName
                    & requestHeaders <>~ [ ("x-ms-lease-action", T.pack . show $ leaseCmd)
                                         , ("Content-Type", inferContentType blobName)
                                         ] <> leaseHeaders leaseCmd
    mkRequest req >>= validate <&> leaseIdFromResponse