module BlueprintSpec (spec) where

import Test.Hspec
import Blueprint

spec :: Spec
spec = parallel $ do
  initializeSpec

initializeSpec :: Spec
initializeSpec = parallel $ describe "initialize" $

 it "initializes a valid project" $ do
   out <- cmd ["init"]

cmd :: [String] -> IO String
cmd args = _
