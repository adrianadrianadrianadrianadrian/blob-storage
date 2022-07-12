module Blob.Data.Blob.Container where

import           Control.Lens
import           Blob.Data.Blob.ContainerProperties
import           Data.Map
import           Data.Text

data Container = Container
  { _name       :: Text
  , _version    :: Text
  , _deleted    :: Text
 -- , _properties :: ContainerProperties
 -- , _metadata   :: Map Text Text
  }
  deriving Show

makeLenses ''Container