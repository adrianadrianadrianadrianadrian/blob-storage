module Blob.IO.Decode where

import           Blob.Abstractions.Decode
import           Blob.Data.Blob
import           Blob.Data.Http
import           Control.Exception
import           Control.Lens
import qualified Data.ByteString               as BS
import qualified Data.CaseInsensitive          as CI
import           Data.Maybe
import           Data.String.Interpolate
import qualified Data.Text                     as T
import           Data.Text.Encoding
import qualified Data.Text.Lazy                as TL
import qualified Network.HTTP.Types            as ExternalHttp
import           Text.XML
import qualified Text.XML.Lens                 as XML

instance Decode IO where
    containers = pureOrThrowIO parseContainers
    blobError  = pureOrThrowIO parseError
    blobs      = pureOrThrowIO parseBlobs

pureOrThrowIO :: (BS.ByteString -> Either SomeException a) -> Response -> IO a
pureOrThrowIO f r = either throwIO pure $ f . fromMaybe mempty $ r ^. body

parseBlobs :: BS.ByteString -> Either SomeException [Blob]
parseBlobs = undefined

parseContainers :: BS.ByteString -> Either SomeException [Container]
parseContainers bs = do
    doc <- parseText def raw
    let containers =
            XML.root
                .   XML.named "EnumerationResults"
                ... XML.named "Containers"
                ... XML.named "Container"
    let t = doc ^.. containers
    pure $ parseContainerElement <$> t
    where raw = decodeStrictUtf8 bs

parseContainerElement :: Element -> Container
parseContainerElement el = Container (el ^. field "Name")
                                     (el ^. field "Version")
                                     (el ^. field "Deleted")
    where field name = XML.named "Container" ... XML.named name . XML.text

parseError :: BS.ByteString -> Either SomeException Error
parseError bs = do
    doc <- parseText def raw
    pure $ Error (doc ^. errorField "Code") (doc ^. errorField "Message")
  where
    raw = decodeStrictUtf8 bs
    errorField name =
        XML.root . XML.named "Error" ... XML.named name . XML.text

stripUtf8Bom :: BS.ByteString -> BS.ByteString
stripUtf8Bom bs = fromMaybe bs (BS.stripPrefix "\239\187\191" bs)

decodeStrictUtf8 :: BS.ByteString -> TL.Text
decodeStrictUtf8 = TL.fromStrict . decodeUtf8 . stripUtf8Bom

testContainer :: BS.ByteString
testContainer = [__i|
        <?xml version="1.0" encoding="utf-8"?>  
        <EnumerationResults ServiceEndpoint="https://myaccount.blob.core.windows.net">  
        <Prefix>string-value</Prefix>  
        <Marker>string-value</Marker>  
        <MaxResults>int-value</MaxResults>  
        <Containers> 
            <Container>  
            <Name>container-name</Name>  
            <Version>container-version</Version>
            <Deleted>true</Deleted>
            <Properties>  
                <Last-Modified>date/time-value</Last-Modified>  
                <Etag>etag</Etag>  
                <LeaseStatus>locked | unlocked</LeaseStatus>  
                <LeaseState>available | leased | expired | breaking | broken</LeaseState>  
                <LeaseDuration>infinite | fixed</LeaseDuration> 
                <PublicAccess>container | blob</PublicAccess>
                <HasImmutabilityPolicy>true | false</HasImmutabilityPolicy>
                <HasLegalHold>true | false</HasLegalHold>
                <DeletedTime>datetime</DeletedTime>
                <RemainingRetentionDays>no-of-days</RemainingRetentionDays>
            </Properties>  
            <Metadata>  
                <metadata-name>value</metadata-name>  
            </Metadata>  
            </Container>  
        </Containers>  
        <NextMarker>marker-value</NextMarker>  
        </EnumerationResults>  
    |]
