module Blob.Data.Blob.BlobContext where

import           Control.Lens
import           Data.Text

data BlobContext = BlobContext
    { _storageAccount :: Text
    , _password       :: Text
    , _host           :: Text
    }

makeLenses ''BlobContext

defaultHost = ".blob.core.windows.net"
defaultBlobContext acc pw = BlobContext acc pw defaultHost

blobDomain :: BlobContext -> Text
blobDomain ctx = "https://" <> ctx ^. storageAccount <> ctx ^. host
