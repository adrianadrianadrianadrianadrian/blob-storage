module Main where

import           Blob.Core
import           Blob.Data
import           Blob.IO
import           Control.Exception
import           Control.Lens
import           Data.Either
import qualified Data.Text                     as T
import qualified Data.ByteString               as BS
import           Data.Maybe

main :: IO ()
main = do
    let context = defaultBlobContext "BLOB_ACC_NAME" "BLOB_ACC_KEY"
    res <- runBlobStorage context $ do
        let containerName = "example-container"
        createContainer containerName
        leaseId <- leaseContainer containerName Acquire 
        putBlob containerName "example-blob" "Hello from example world"
        printFirstBlobDetails
        leaseContainer containerName (Release $ fromJust leaseId)
    pure ()

printFirstBlobDetails :: BlobStorage ()
printFirstBlobDetails = do
        containers <- listContainers
        let containerName = head containers ^. name
        withIO . print $ "First container: " <> containerName

        blobs <- listBlobs containerName
        let first = head blobs
        let props = first ^. blobProperties
        withIO . print $ "Name: " <> first ^. blobName <> "\nBytes " <> (T.pack . show $ props ^. contentByteLength)