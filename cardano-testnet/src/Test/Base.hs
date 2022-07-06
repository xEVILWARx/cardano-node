module Test.Base
  ( integration
  , isLinux
  ) where

import           Data.Bool (Bool)
import           Data.Eq (Eq (..))
import           Data.Function
import           GHC.Stack (HasCallStack)
import           System.Info (os)

import qualified Hedgehog as H
import qualified Hedgehog.Extras.Test.Base as H


integration :: HasCallStack => H.Integration () -> H.Property
integration = H.withTests 1 . H.propertyOnce

isLinux :: Bool
isLinux = os == "linux"
