module Blob.Data.Blob.LeaseState where

import           Data.Text

data LeaseState
    = Available
    | Leased
    | Expired
    | Breaking
    | Broken
    deriving Show

maybeLeaseState :: Text -> Maybe LeaseState
maybeLeaseState input = case toLower input of
    "available" -> Just Available
    "leased"    -> Just Leased
    "expired"   -> Just Expired
    "breaking"  -> Just Breaking
    "broken"    -> Just Broken
    _           -> Nothing
