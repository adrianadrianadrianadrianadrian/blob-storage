module Main where

import           Blob.Core
import           Blob.Data
import           Blob.IO
import           Control.Exception
import           Control.Lens
import           Control.Monad.Trans
import           Data.Either
import qualified Data.Text                     as T

main :: IO ()
main = do
    let context = defaultBlobContext "" ""
    firstBlobDetails <- runBlobStorage context $ do
        containerName <- printFirstContainerName
        blobs <- listBlobs containerName
        let first = head blobs
        let props = first ^. blobProperties
        pure $ "Name: " <> first ^. blobName <> "\nBytes " <> (T.pack . show $ props ^. contentByteLength)
    print firstBlobDetails

printFirstContainerName :: BlobStorage T.Text
printFirstContainerName = do
    containers <- listContainers
    let containerName = head containers ^. name
    lift . print $ "First container: " <> containerName
    pure containerName