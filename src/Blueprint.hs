module Blueprint where

import Blueprint.CLIOptions
import Blueprint.Run

main :: IO ()
main = getOptions >>= run
