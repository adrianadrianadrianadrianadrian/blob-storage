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
    it "findHeader return Nothing when no matching header found" $ forAll keyAndHeaders $
      \(k, headers) -> isNothing $ H.findHeader (pack k) headers

  describe "Param" $ do
    it "queryString is correctly formed" $ do
      H.queryString [("k", "v")] `shouldBe` "?k=v"
      H.queryString [("k", "v"), ("k2", "v2")] `shouldBe` "?k=v&k2=v2"
      H.queryString [] `shouldBe` ""

keyAndHeaders :: Gen (String, [H.Header])
keyAndHeaders = do
  k <- arbitrary :: Gen String
  headers <- listOf (headerGen `suchThat` ((/= pack k) . fst))
  pure (k, headers)
  where
    headerGen = do
      k <- (arbitrary :: Gen String)
      v <- (arbitrary :: Gen String)
      pure (pack k, pack v)
