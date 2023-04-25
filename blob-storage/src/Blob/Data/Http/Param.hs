module Blob.Data.Http.Param where

import qualified Data.Text as T

type Param = (T.Text, T.Text)

queryString :: [Param] -> T.Text
queryString [] = ""
queryString params = (<>) "?" . foldr pairs mempty $ params
  where
    pairs (a, b) c = a <> "=" <> b <> (if c == mempty then c else "&" <> c)
