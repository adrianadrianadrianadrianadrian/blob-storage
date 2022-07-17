module Blob.Data.Blob.BlobProperties where

import           Control.Lens
import           Data.Text

data BlobProperties = BlobProperties
    { _contentType       :: Text
    , _contentByteLength :: Int
    }
    deriving Show

makeLenses ''BlobProperties
