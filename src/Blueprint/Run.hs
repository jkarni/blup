module Blueprint.Run where

import Blueprint.CLIOptions
import Blueprint.Templates as Templates
import System.Exit
import Control.Monad
import System.Directory
import System.Process
import System.Environment

run :: Options -> IO ()
run opts = case opts of
  OptionsCreate cOpts -> create cOpts
  OptionsEdit eOpts -> edit eOpts
  OptionsInitialize iOpts -> initialize iOpts
  OptionsCheck cOpts -> check cOpts
  OptionsRun rOpts -> run' rOpts

create :: CreateOptions -> IO ()
create opts = case opts of
  CreateOptionsPackage pkg -> do
    createDirectoryIfMissing True ("nix/packages/" <> pkg)
    let file = "nix/packages/" <> pkg <> "/default.nix"
    ensureFileDoesntExist file
    writeFile file Templates.basicPackage
    openInEditor file
  CreateOptionsCheck check -> do
    createDirectoryIfMissing True ("nix/checks/" <> check)
    let file = "nix/checks/" <> check <> "/default.nix"
    ensureFileDoesntExist file
    writeFile file Templates.basicCheck
    openInEditor file
  CreateOptionsDevShell devShell -> do
    createDirectoryIfMissing True "nix/devshells"
    let file = "nix/devshells/" <> devShell <> ".nix"
    ensureFileDoesntExist file
    writeFile file Templates.basicDevShell
    openInEditor file
  CreateOptionsHost host -> do
    createDirectoryIfMissing True ("nix/hosts/" <> host)
    let file = "nix/hosts/" <> host <> "/configuration.nix"
    ensureFileDoesntExist file
    writeFile file Templates.basicNixosConfig
    openInEditor file
  where
    ensureFileDoesntExist :: FilePath -> IO ()
    ensureFileDoesntExist path = do
      exists <- doesFileExist path
      when exists $ do
        putStrLn $
          "File " <> path <> " already exists. Did you intend to edit it? If so, use the 'edit' command."
        exitFailure

edit :: EditOptions -> IO ()
edit opts = case opts of
  EditOptionsPackage pkg -> do
    let file = "nix/packages/" <> pkg <> "/default.nix"
    ensureFileExists file
    openInEditor file
  EditOptionsCheck check -> do
    let file = "nix/checks/" <> check <> "/default.nix"
    ensureFileExists file
    openInEditor file
  EditOptionsDevShell devShell -> do
    let file = "nix/checks/" <> devShell <> ".nix"
    ensureFileExists file
    openInEditor file
  where
    ensureFileExists :: FilePath -> IO ()
    ensureFileExists path = do
      exists <- doesFileExist path
      unless exists $ do
        putStrLn $
          "File " <> path <> " doesn't exist. Did you intend to create it? If so, use the 'create' command."
        exitFailure

initialize :: InitializeOptions -> IO ()
initialize opts = do
  exists <- doesFileExist "flake.nix"
  when exists $ do
    putStrLn "There's already a flake.nix file in this directory! If you want to initialize a blueprint project, delete if frirst."
    exitFailure
  writeFile "flake.nix" (basicFlake $ nixpkgs opts)

check :: CheckOptions -> IO ()
check opts = do
  callProcess "nix" ["flake", "check", ".#checks." <> checkName opts ]

run' :: RunOptions -> IO ()
run' opts = case opts of
  RunOptionsVM host -> do
    outpath <- readProcess "nix" ["build", ".#nixosConfigurations." <> host <> ".config.system.build.vm", "--print-out-paths"] ""
    callProcess (outpath <> "/bin/run-" <> host <> "-vm") []

openInEditor :: FilePath -> IO ()
openInEditor file = do
  mEditor <- lookupEnv "EDITOR"
  case mEditor of
    Nothing -> callProcess "nano" [file]
    Just editor -> callProcess editor [file]
