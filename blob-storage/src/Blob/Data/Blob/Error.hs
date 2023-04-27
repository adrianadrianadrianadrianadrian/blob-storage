module Blob.Data.Blob.Error where

import           Control.Lens
import qualified Data.Text    as T

data Error = Error
    { _code    :: T.Text
    , _message :: T.Text
    }
    deriving Show

makeLenses ''Error
