module Blob.Data.Blob.Container where

import           Blob.Data.Blob.ContainerProperties
import           Control.Lens
import           Data.Text

data Container = Container
  { _name       :: Text
  , _properties :: ContainerProperties
  }
  deriving Show

makeLenses ''Container
