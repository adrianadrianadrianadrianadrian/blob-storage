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
    runBlobDB context $ do
        containerName <- printFirstContainerName
        printFirstBlobContents containerName
    pure ()

printFirstContainerName :: BlobDB IO T.Text
printFirstContainerName = do
    containers <- listContainers
    let containerName = head containers ^. name
    lift $ print containerName
    pure containerName

printFirstBlobContents :: T.Text -> BlobDB IO ()
printFirstBlobContents containerName = do
    blobs <- listBlobs containerName
    let firstBlobName = head blobs ^. blobName
    content <- getBlob containerName firstBlobName
    lift . print $ content
