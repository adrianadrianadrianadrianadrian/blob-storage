module Blob.Data.Http.Request where

import           Blob.Data.Http.Header
import           Blob.Data.Http.Method
import           Blob.Data.Http.Param
import           Control.Lens
import           Data.ByteString
import           Data.Text

data Request = Request
    { _method         :: Method
    , _domain         :: Text
    , _path           :: Maybe Text
    , _params         :: [Param]
    , _requestHeaders :: [Header]
    }
    deriving Show

makeLenses ''Request

defaultGET d = Request GET d Nothing [] []
defaultPUT d b = Request (PUT b) d Nothing [] []
defaultDELETE d = Request DELETE d Nothing [] []
