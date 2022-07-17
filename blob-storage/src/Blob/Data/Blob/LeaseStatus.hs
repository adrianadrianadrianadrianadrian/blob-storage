module Blob.Data.Blob.LeaseStatus where

import           Data.Text

data LeaseStatus
    = Locked
    | Unlocked
    deriving Show

maybeLeaseStatus :: Text -> Maybe LeaseStatus
maybeLeaseStatus input = case toLower input of
    "locked"   -> Just Locked
    "unlocked" -> Just Unlocked
    _          -> Nothing
