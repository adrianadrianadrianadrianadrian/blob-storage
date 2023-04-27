module Blob.Data.Http.Response where

import           Blob.Data.Http.Header
import           Control.Lens
import           Data.ByteString
import qualified Network.HTTP.Types    as ExternalHttp

data Response = Response
    { _responseHeaders :: [Header]
    , _status          :: ExternalHttp.Status
    , _body            :: Maybe ByteString
    }
    deriving Show

makeLenses ''Response

isError :: Response -> Bool
isError res =
    let code = res ^. status & ExternalHttp.statusCode
    in  code /= 200 && code /= 201 && code /= 202
