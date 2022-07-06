
module Test.Util
  ( ignoreOn
  , ignoreOnWindows
  , ignoreOnMac
  , ignoreOnMacAndWindows
  , disabled
  ) where

import           Data.Bool (bool)
import           Data.String (IsString (..))
import           Hedgehog (Property)
import           Hedgehog.Extras.Stock.OS (isWin32)
import           Prelude
import           Test.Tasty.ExpectedFailure (wrapTest)
import           Test.Tasty.Providers (testPassed)
import           Test.Tasty.Runners (Result (resultShortDescription), TestTree)

import qualified System.Info as SYS
import qualified Test.Tasty.Hedgehog as H

type Os = String

ignoreOnWindows :: String -> Property -> TestTree
ignoreOnWindows pName prop =
  bool id (ignoreOn "Windows") isWin32 $ H.testPropertyNamed pName (fromString pName) prop

ignoreOnMac :: String -> Property -> TestTree
ignoreOnMac pName prop =
  bool id (ignoreOn "MacOS") isMacOS $ H.testPropertyNamed pName (fromString pName) prop

ignoreOnMacAndWindows :: String -> Property -> TestTree
ignoreOnMacAndWindows pName prop =
  bool id (ignoreOn "MacOS and Windows") (isMacOS || isWin32) $ H.testPropertyNamed pName (fromString pName) prop

isMacOS :: Bool
isMacOS = SYS.os == "darwin"

ignoreOn :: Os -> TestTree -> TestTree
ignoreOn os = wrapTest $ const $ return $
  (testPassed ("IGNORED on " <> os))
    { resultShortDescription = "IGNORED on " <> os
    }

disabled :: String -> Property -> TestTree
disabled pName prop = ignoreOn "Disabled" $ H.testPropertyNamed pName (fromString pName) prop
