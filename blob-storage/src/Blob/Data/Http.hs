module Blob.Data.Http
  ( module Blob.Data.Http.Header
  , module Blob.Data.Http.Response
  , module Blob.Data.Http.Request
  , module Blob.Data.Http.Method
  , module Blob.Data.Http.Param

    -- defaults
  , defaultGET
  , defaultPUT
  , urlFromRequest
  ) where

import           Blob.Data.Http.Header
import           Blob.Data.Http.Method
import           Blob.Data.Http.Param
import           Blob.Data.Http.Request
import           Blob.Data.Http.Response
import           Control.Lens
import           Data.Maybe
import           Data.Text

urlFromRequest :: Request -> Text
urlFromRequest r = d <> "/" <> p <> queryString (r ^. params)
 where
  p = fromMaybe mempty $ r ^. path
  d = r ^. domain
