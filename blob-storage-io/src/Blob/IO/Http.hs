module Blob.IO.Http where

import           Blob.Abstractions.Http
import           Blob.Data.Http
import           Control.Lens
import qualified Data.ByteString.Lazy          as LBS
import qualified Data.CaseInsensitive          as CI
import           Data.Maybe
import           Data.Text
import           Data.Text.Encoding
import qualified Network.HTTP.Types            as External
import qualified Network.Wreq                  as W

instance Http IO where
  mkRequest r = toInternalResponse <$> case r ^. method of
    GET      -> W.getWith opts url
    PUT body -> W.putWith opts url body
    DELETE   -> W.deleteWith opts url
   where
    headers = toExternalHeader <$> r ^. requestHeaders
    url     = unpack . urlFromRequest $ r
    opts    = W.defaults & W.headers <>~ headers 
                         & W.checkResponse ?~ ignore

toExternalHeader :: Header -> External.Header
toExternalHeader = over _1 CI.mk . over each encodeUtf8

toInternalHeader :: External.Header -> Header
toInternalHeader = over each decodeUtf8 . over _1 CI.original

toInternalResponse :: W.Response LBS.ByteString -> Response
toInternalResponse res = Response
  (toInternalHeader <$> res ^. W.responseHeaders)
  (res ^. W.responseStatus)
  (LBS.toStrict <$> res ^? W.responseBody)

ignore _ _ = pure ()
