{-# LANGUAGE BangPatterns #-}

module Cardano.CLI.IO.Lazy
  ( replicateM
  , sequenceM
  , traverseM
  , forM
  ) where

import Control.Applicative (Applicative((<*>), pure), (<$>))
import Control.Monad (Monad(..))
import Control.Monad.IO.Unlift (MonadIO(liftIO), MonadUnliftIO, askUnliftIO, UnliftIO(unliftIO))
import Data.Function (($), (.), flip)
import Data.Int (Int)
import System.IO (IO)

import qualified Data.List as L
import qualified System.IO.Unsafe as IO

replicateM :: MonadUnliftIO m => Int -> m a -> m [a]
replicateM n f = sequenceM (L.replicate n f)

sequenceM :: MonadUnliftIO m => [m a] -> m [a]
sequenceM as = do
  f <- askUnliftIO
  liftIO $ sequenceIO (L.map (unliftIO f) as)

-- | Traverses the function over the list and produces a lazy list in a
-- monadic context.
--
-- It is intended to be like the "standard" 'traverse' except
-- that the list is generated lazily.
traverseM :: MonadUnliftIO m => (a -> m b) -> [a] -> m [b]
traverseM f as = do
  u <- askUnliftIO
  liftIO $ IO.unsafeInterleaveIO (go u as)
  where
    go _ [] = pure []
    go !u (v:vs) = do
      !res <- unliftIO u (f v)
      rest <- IO.unsafeInterleaveIO (go u vs)
      pure (res:rest)

forM :: MonadUnliftIO m => [a] -> (a -> m b) -> m [b]
forM = flip traverseM

-- Internal
sequenceIO :: [IO a] -> IO [a]
sequenceIO = IO.unsafeInterleaveIO . go
  where go :: [IO a] -> IO [a]
        go []       = return []
        go (fa:fas) = (:) <$> fa <*> IO.unsafeInterleaveIO (go fas)
