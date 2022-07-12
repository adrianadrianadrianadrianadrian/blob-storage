module Blob.Data.Http.Header where

import qualified Data.List                     as List
import qualified Data.Text                     as T

type Header = (T.Text, T.Text)

findHeader :: T.Text -> [Header] -> Maybe Header
findHeader key = List.find $ (== key) . fst