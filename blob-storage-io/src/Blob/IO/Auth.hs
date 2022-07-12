module Blob.IO.Auth where

import           Blob.Abstractions.Auth
import           Blob.Data.Blob
import           Blob.Data.Http
import           Control.Lens
import qualified Crypto.Hash.SHA256            as SHA256
import qualified Data.ByteString.Base64        as Base64
import           Data.List
import           Data.Maybe
import           Data.String.Interpolate
import qualified Data.Text                     as T
import           Data.Text.Encoding
import           Data.Time

instance Auth IO where
    auth ctx req = do
        now <- T.pack . formatTime defaultTimeLocale "%a, %d %b %Y %X GMT" <$> getCurrentTime
        let headers = [("x-ms-version", currentSupportedVersion), ("x-ms-date", now)]
        let signMe = textToSign req (canonicalizedHeaders $ headers <> req ^. requestHeaders) (canonicalizedResource ctx req)
        let authHeader = 
                ("Authorization", [i|SharedKey #{ctx ^. storageAccount}:#{sign (ctx ^. password) signMe}|])
        pure $ req & requestHeaders <>~ authHeader : headers
        where
            currentSupportedVersion = "2021-08-06"

textToSign :: Request -> T.Text -> T.Text -> T.Text
textToSign req canonicalHeaders canonicalResource =
    [__i|
        #{req ^. method}
        #{valueOrEmpty "Content-Encoding" hs}
        #{valueOrEmpty "Content-Language" hs}
        #{valueOrEmpty "Content-Length" hs}
        #{valueOrEmpty "Content-MD5" hs}
        #{valueOrEmpty "Content-Type" hs}
        #{valueOrEmpty "Date" hs}
        #{valueOrEmpty "If-Modified-Since" hs}
        #{valueOrEmpty "If-Match" hs}
        #{valueOrEmpty "If-None-Match" hs}
        #{valueOrEmpty "If-Unmodified-Since" hs}
        #{valueOrEmpty "Range" hs}
        #{canonicalHeaders <> canonicalResource}
    |]
    where
        valueOrEmpty key = maybe mempty snd . findHeader key 
        hs = req ^. requestHeaders

canonicalizedHeaders :: [Header] -> T.Text
canonicalizedHeaders = foldr pairs mempty . sortBy compareFst . filtered
    where
        filtered = filter (T.isInfixOf "x-ms" . fst) 
        pairs (a, b) c = T.toLower a <> ":" <> b <> "\n" <> c

canonicalizedResource :: BlobContext -> Request -> T.Text
canonicalizedResource ctx r =
    "/"
    <> ctx ^. storageAccount
    <> "/"
    <> fromMaybe mempty (r ^. path)
    <> ps
    where
        ps = foldr pairs mempty . sortBy compareFst $ r ^. params
        pairs (a, b) c = "\n" <> a <> ":" <> b <> c

sign :: T.Text -> T.Text -> T.Text
sign key = 
    let bkey = Base64.decodeLenient . encodeUtf8 $ key 
    in decodeUtf8 . Base64.encode . SHA256.hmac bkey . encodeUtf8

compareFst :: Ord a => (a, b) -> (a, c) -> Ordering
compareFst l = compare (fst l) . fst
