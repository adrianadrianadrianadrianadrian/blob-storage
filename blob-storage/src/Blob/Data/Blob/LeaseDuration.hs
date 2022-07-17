module Blob.Data.Blob.LeaseDuration where

import           Data.Text
import           Text.Read

data LeaseDuration
    = Infinite
    | Fixed Int
    deriving Show

maybeLeaseDuration :: Text -> Maybe LeaseDuration
maybeLeaseDuration input = (readMaybe . unpack $ input) >>= \duration ->
    if duration == -1 then Just Infinite else Just . Fixed $ duration

