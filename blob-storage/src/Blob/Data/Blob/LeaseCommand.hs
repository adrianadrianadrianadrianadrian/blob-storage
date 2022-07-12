module Blob.Data.Blob.LeaseCommand where

import Blob.Data.Blob.LeaseId

data LeaseCommand = Acquire
                  | Renew LeaseId
                  | Change LeaseId
                  | Release LeaseId
                  | Break
                  deriving Show