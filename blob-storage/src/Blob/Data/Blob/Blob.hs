module Blob.Data.Blob.Blob where

import           Blob.Data.Blob.BlobProperties
import           Control.Lens
import           Data.Text

data Blob = Blob
  { _blobName       :: Text
  , _blobProperties :: BlobProperties
  }
  deriving Show

makeLenses ''Blob
