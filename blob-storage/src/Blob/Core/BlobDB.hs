module Blob.Core.BlobDB where

import           Control.Monad.Except
import           Control.Monad.Reader
import           Blob.Data.Blob

newtype BlobDB m a = BlobDB { unBlobDB :: ReaderT BlobContext (ExceptT Error m) a }
    deriving (Monad, Functor, Applicative, MonadReader BlobContext, MonadError Error)

runBlobDB :: Monad m => BlobContext -> BlobDB m a -> m (Either Error a)
runBlobDB ctx = runExceptT . flip runReaderT ctx . unBlobDB
