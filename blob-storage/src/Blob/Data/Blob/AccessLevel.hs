module Blob.Data.Blob.AccessLevel where

import           Data.Text

data AccessLevel
    = ContainerLevel
    | BlobLevel
    deriving Show

maybeAccesslevel :: Text -> Maybe AccessLevel
maybeAccesslevel input = case toLower input of
    "container" -> Just ContainerLevel
    "blob"      -> Just BlobLevel
    _           -> Nothing
