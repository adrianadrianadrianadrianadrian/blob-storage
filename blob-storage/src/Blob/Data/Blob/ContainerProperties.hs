module Blob.Data.Blob.ContainerProperties where

import           Blob.Data.Blob.AccessLevel
import           Blob.Data.Blob.LeaseDuration
import           Blob.Data.Blob.LeaseState
import           Blob.Data.Blob.LeaseStatus
import           Data.Text

data ContainerProperties = ContainerProperties
    { _etag                   :: Text
    , _leaseStatus            :: LeaseStatus
    , _leaseState             :: LeaseState
    , _leaseDuration          :: LeaseDuration
    , _publicAccess           :: AccessLevel
    , _hasImmutabilityPolicy  :: Bool
    , _hasLegalHold           :: Bool
    , _deletedTime            :: Text
    , _remainingRetentionDays :: Int
    , _lastModified           :: Text
    }
    deriving Show
