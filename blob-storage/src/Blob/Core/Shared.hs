module Blob.Core.Shared where

import           Blob.Abstractions.Decode
import           Blob.Core.BlobDB
import           Blob.Core.Derivations
import           Blob.Data.Blob
import           Blob.Data.Http
import           Control.Lens
import           Control.Monad.Except
import qualified Data.Text                     as T
import           Text.Read

validate :: (Decode m) => Response -> BlobDB m Response
validate r = if isError r then blobError r >>= throwError else pure r

leaseHeaders :: LeaseCommand -> [Header]
leaseHeaders (Renew id          ) = [leaseHeader id]
leaseHeaders (Change current new) = [leaseHeader current, ("x-ms-proposed-lease-id", T.pack . show $ new)]
leaseHeaders (Release id        ) = [leaseHeader id]
leaseHeaders Acquire              = [("x-ms-lease-duration", "-1")]
leaseHeaders Break                = []

leaseHeader :: LeaseId -> Header
leaseHeader id = ("x-ms-lease-id", T.pack . show $ id)

leaseIdFromResponse :: Response -> Maybe LeaseId
leaseIdFromResponse res = maybeLeaseHeader >>= (readMaybe . T.unpack) . snd
  where maybeLeaseHeader = findHeader "x-ms-lease-id" $ res ^. responseHeaders
