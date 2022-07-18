module Blob.Data.Blob.LeaseCommand where

import           Blob.Data.Blob.LeaseId

data LeaseCommand = Acquire
                  | Renew LeaseId
                  | Change LeaseId LeaseId
                  | Release LeaseId
                  | Break

instance Show LeaseCommand where
    show Acquire      = "acquire"
    show (Renew _   ) = "renew"
    show (Change _ _) = "change"
    show (Release _ ) = "release"
    show Break        = "break"
