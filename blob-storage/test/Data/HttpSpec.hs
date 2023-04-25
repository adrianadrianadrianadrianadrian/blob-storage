{-# LANGUAGE OverloadedStrings #-}

module Data.HttpSpec (spec) where

import qualified Blob.Data.Http  as H
import           Data.Maybe
import           Data.Text
import           Generators
import           Test.Hspec
import           Test.QuickCheck
import           Text.Read

spec :: Spec
spec = do
  describe "Header" $ do
    it "findHeader returns matching header" $ do
      let matchingHeader = ("key", "value")
      let headers = [matchingHeader, ("key2", "value2")]
      H.findHeader "key" headers `shouldBe` Just matchingHeader

  describe "Param" $ do
    it "queryString is correctly formed" $ do
      H.queryString [("k", "v")] `shouldBe` "?k=v"
      H.queryString [("k", "v"), ("k2", "v2")] `shouldBe` "?k=v&k2=v2"
      H.queryString [] `shouldBe` ""
