module Blob.Data.Blob.LeaseState where

data LeaseState
    = Available
    | Leased
    | Expired
    | Breaking
    | Broken
    deriving (Show)
