module Blob.Data.Http.Method where

import           Data.ByteString

data Method = GET
            | PUT ByteString
            | DELETE

instance Show Method where
    show GET     = "GET"
    show (PUT _) = "PUT"
    show DELETE  = "DELETE"
