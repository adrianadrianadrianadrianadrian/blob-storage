{-# LANGUAGE OverloadedStrings #-}

module Data.BlobSpec (spec) where

import qualified Blob.Data.Blob  as B
import           Data.Maybe
import           Data.Text
import           Generators
import           Test.Hspec
import           Test.QuickCheck
import           Text.Read

spec :: Spec
spec = do
  describe "maybeLeaseDuration" $ do
    it "should return 'Just Infinite'" $ do
      B.maybeLeaseDuration "-1" `shouldBe` Just B.Infinite
    it "should return 'Just Fixed x'" $
      forAll (excludeInt (-1)) $
        \x -> B.maybeLeaseDuration (pack . show $ x) == Just (B.Fixed x)
    it "should return 'Nothing'" $ do
      forAll nonNumericString $
        \i -> B.maybeLeaseDuration (pack i) `shouldBe` Nothing
