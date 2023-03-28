module Blob.IO.Decode where

import           Blob.Abstractions.Decode
import           Blob.Data.Blob
import           Blob.Data.Blob.ContainerProperties
import           Blob.Data.Http
import           Control.Exception
import           Control.Lens
import qualified Data.ByteString               as BS
import qualified Data.CaseInsensitive          as CI
import           Data.Map                      as Map
import           Data.Maybe
import           Data.String.Interpolate
import qualified Data.Text                     as T
import           Data.Text.Encoding
import qualified Data.Text.Lazy                as TL
import           GHC.Exception
import qualified Network.HTTP.Types            as ExternalHttp
import           Text.Read
import           Text.XML
import qualified Text.XML.Lens                 as XML

instance Decode IO where
    containers  = pureOrThrowIO parseContainers
    blobError   = pureOrThrowIO parseError
    blobs       = pureOrThrowIO parseBlobs
    blobContent = pure . view body

pureOrThrowIO :: (BS.ByteString -> Either SomeException a) -> Response -> IO a
pureOrThrowIO parse r = either throwIO pure $ parse . fromMaybe mempty $ r ^. body

errorWhileParsing :: BS.ByteString -> Either SomeException a
errorWhileParsing = Left . errorCallException . ("Error parsing: " <>) . show

parseContainers :: BS.ByteString -> Either SomeException [Container]
parseContainers bs = do
    doc <- parseText def . decodeStrictUtf8 $ bs
    let containers =
            XML.root
                .   XML.named "EnumerationResults"
                ... XML.named "Containers"
                ... XML.named "Container"
    let maybeContainers =
            sequence $ parseContainerElement <$> doc ^.. containers
    maybe (errorWhileParsing bs) Right maybeContainers

parseContainerElement :: Element -> Maybe Container
parseContainerElement el = do
    props <- parseContainerProperties el
    pure Container { _name       = field "Name"
                   , _properties = props
                   }
  where
    field name = el ^. XML.named "Container" ... XML.named name . XML.text

parseContainerProperties :: Element -> Maybe ContainerProperties
parseContainerProperties el = do
    leaseStatus     <- maybeLeaseStatus . properties $ "LeaseStatus"
    leaseState      <- maybeLeaseState . properties $ "LeaseState"

    pure $ ContainerProperties
        { _etag                   = properties "Etag"
        , _leaseStatus            = leaseStatus
        , _leaseState             = leaseState
        , _leaseDuration          = maybeProperties "LeaseDuration" >>= maybeLeaseDuration
        , _publicAccess           = fromMaybe Private (maybeAccesslevel . properties $ "PublicAccess")
        , _hasImmutabilityPolicy  = "true" == (T.toLower . properties $ "HasImmutabilityPolicy")
        , _hasLegalHold           = "true" == (T.toLower . properties $ "HasLegalHold")
        , _lastModified           = properties "Last-Modified"
        }
  where
    properties name = el ^. scope name
    maybeProperties name = el ^? scope name
    scope name = XML.named "Container" ... XML.named "Properties" ... XML.named name . XML.text

parseBlobs :: BS.ByteString -> Either SomeException [Blob]
parseBlobs bs = do
    doc <- parseText def . decodeStrictUtf8 $ bs
    let blobs =
            XML.root
                .   XML.named "EnumerationResults"
                ... XML.named "Blobs"
                ... XML.named "Blob"
    let maybeBlobs =
            sequence $ parseBlobElement <$> doc ^.. blobs
    maybe (errorWhileParsing bs) Right maybeBlobs

parseBlobElement :: Element -> Maybe Blob
parseBlobElement el = do
    props <- parseBlobProperties el
    pure Blob { _blobName       = field "Name"
              , _blobProperties = props
              }
  where
    field name = el ^. XML.named "Blob" ... XML.named name . XML.text

parseBlobProperties :: Element -> Maybe BlobProperties
parseBlobProperties el = do
    byteLenth <- readMaybe . T.unpack . prop $ "Content-Length"
    pure BlobProperties { _contentType = prop "Content-Type"
                        , _contentByteLength = byteLenth
                        }
    where
        prop name = el ^. XML.named "Blob" ... XML.named "Properties" ... XML.named name . XML.text

parseError :: BS.ByteString -> Either SomeException Error
parseError bs = do
    doc <- parseText def . decodeStrictUtf8 $ bs
    pure $ Error { _code    = doc ^. errorField "Code"
                 , _message = doc ^. errorField "Message"
                 }
  where
    errorField name =
        XML.root . XML.named "Error" ... XML.named name . XML.text

stripUtf8Bom :: BS.ByteString -> BS.ByteString
stripUtf8Bom bs = fromMaybe bs (BS.stripPrefix "\239\187\191" bs)

decodeStrictUtf8 :: BS.ByteString -> TL.Text
decodeStrictUtf8 = TL.fromStrict . decodeUtf8 . stripUtf8Bom