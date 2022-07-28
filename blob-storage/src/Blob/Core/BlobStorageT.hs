module Blob.Core.BlobStorageT where

import           Blob.Data.Blob
import           Control.Monad.Except
import           Control.Monad.Reader

newtype BlobStorageT m a = BlobStorageT { unBlobStorageT :: ReaderT BlobContext (ExceptT Error m) a }
    deriving (Monad, Functor, Applicative, MonadReader BlobContext, MonadError Error)

type BlobStorage = BlobStorageT IO

runBlobStorageT :: Monad m => BlobContext -> BlobStorageT m a -> m (Either Error a)
runBlobStorageT ctx = runExceptT . flip runReaderT ctx . unBlobStorageT

runBlobStorage :: BlobContext -> BlobStorage a -> IO (Either Error a)
runBlobStorage = runBlobStorageT