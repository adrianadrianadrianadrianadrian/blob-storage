module Generators where

import           Data.Maybe
import           Test.QuickCheck
import           Text.Read

excludeInt :: Int -> Gen Int
excludeInt exclude = (arbitrary :: Gen Int) `suchThat` (/= exclude)

nonIntString :: Gen String
nonIntString = (arbitrary :: Gen String) `suchThat` numeric
  where
    numeric input = isNothing (readMaybe input :: Maybe Int)
