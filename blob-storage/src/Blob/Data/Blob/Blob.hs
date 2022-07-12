module Blob.Data.Blob.Blob where

import           Data.Text
import Control.Lens

data Blob = Blob
  { _blobName       :: Text
  }
  deriving Show

makeLenses ''Blob