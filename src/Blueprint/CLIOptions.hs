module Blueprint.CLIOptions where

import Options.Applicative
import Data.Tuple
import Data.List

data Options where
  OptionsCreate :: CreateOptions -> Options
  OptionsEdit :: EditOptions -> Options
  OptionsInitialize :: InitializeOptions -> Options
  OptionsCheck :: CheckOptions -> Options
  OptionsRun :: RunOptions -> Options
  deriving (Eq, Show)

data CreateOptions where
  CreateOptionsPackage :: String -> CreateOptions
  CreateOptionsCheck :: String -> CreateOptions
  CreateOptionsDevShell :: String -> CreateOptions
  CreateOptionsHost :: String -> CreateOptions
  deriving (Eq, Show)

data EditOptions where
  EditOptionsPackage :: String -> EditOptions
  EditOptionsCheck :: String -> EditOptions
  EditOptionsDevShell :: String -> EditOptions
  deriving (Eq, Show)

data CheckOptions = CheckOptions
  { checkName :: String }
  deriving (Eq, Show)

data InitializeOptions = InitializeOptions
  { nixpkgs :: NixpkgsVersion }
  deriving (Eq, Show)

data RunOptions where
  RunOptionsVM :: String -> RunOptions
  deriving (Eq, Show)

options :: Parser Options
options = hsubparser
  (command "init"
    (info
      (OptionsInitialize <$> initializeOptions)
      (progDesc "Initialize a new blueprint project"
      <> defaultHeader
      ))
  <>
   command "create"
    (info
      (OptionsCreate <$> createOptions)
      (progDesc "Create a new package, check, host, or devshell"
      <> defaultHeader
      ))
  <> command "edit"
    (info
      (OptionsEdit <$> editOptions)
      (progDesc "Edit an existing package, check, host, or devshell"
      <> defaultHeader
      ))
  <> command "check"
    (info
      (OptionsCheck <$> checkOptions)
      (progDesc "Run a check"
      <> defaultHeader
      ))
  <> command "run"
    (info
      (OptionsRun <$> runOptions)
      (progDesc "Run a VM"
      <> defaultHeader
      ))
  )

createOptions :: Parser CreateOptions
createOptions = subparser
  (command "package"
    (info
      (CreateOptionsPackage <$> textArg "PACKAGE")
      (progDesc "Create a new package"))
  <> command "check"
    (info
      (CreateOptionsCheck <$> textArg "CHECK")
      (progDesc "Create a new check"))
  <> command "devshell"
    (info
      (CreateOptionsDevShell <$> textArg "DEVSHELL")
      (progDesc "Create a new devshell"))
  <> command "host"
    (info
      (CreateOptionsHost <$> textArg "HOST")
      (progDesc "Create a new host (NixOS configuration)"))
  )
  where
    textArg = argument str . metavar

editOptions :: Parser EditOptions
editOptions = subparser
  (command "package"
    (info
      (EditOptionsPackage <$> textArg "PACKAGE")
      (progDesc "Edit a package"))
  <> command "check"
    (info
      (EditOptionsCheck <$> textArg "CHECK")
      (progDesc "Edit a check"))
  <> command "devshell"
    (info
      (EditOptionsDevShell <$> textArg "DEVSHEL")
      (progDesc "Edit a devshell"))
  )
  where
    textArg = argument str . metavar

initializeOptions :: Parser InitializeOptions
initializeOptions = InitializeOptions
  <$> option parseNixpkgsRef
    (long "nixpkgs"
    <> short 'n'
    <> value NixosUnstable
    <> metavar "VERSION"
    <> showDefault
    <> help "What nixpkgs version to use ")
  where
    parseNixpkgsRef = eitherReader $ \r -> case lookup r (swap <$> nixpkgsVersionStr) of
      Nothing -> Left $
        "Nixpkgs version '" <> r <> "' not recognized. Allowed values:\n  - "
         <> intercalate "\n  - " (snd <$> nixpkgsVersionStr)
      Just v -> pure v

checkOptions :: Parser CheckOptions
checkOptions = CheckOptions
  <$> argument str (metavar "CHECK" <> help "What check to run")

runOptions :: Parser RunOptions
runOptions = subparser
  (command "vm"
    (info
      (RunOptionsVM <$> textArg "HOST")
      (progDesc "Runs a VM based on the specified host")))
  where
    textArg = argument str . metavar

data NixpkgsVersion
  = NixosUnstable
  | Nixos2311
  | Nixos2311Small
  | Nixos2405
  | Nixos2405Small
  deriving (Eq)

instance Show NixpkgsVersion where
  show x = case lookup x nixpkgsVersionStr of
    Nothing -> error "impossible"
    Just v -> v

nixpkgsVersionStr :: [(NixpkgsVersion, String)]
nixpkgsVersionStr =
  [ (NixosUnstable, "unstable")
  , (Nixos2311, "23.11")
  , (Nixos2311Small, "23.11-small")
  , (Nixos2405, "24.05")
  , (Nixos2405Small, "24.05-small")
  ]


getOptions :: IO Options
getOptions = execParser opts
  where
    opts = info (options <**> helper)
      ( fullDesc
      <> progDesc "Configure and run blueprint-nix projects"
      <> defaultHeader)

defaultHeader :: InfoMod a
defaultHeader = header "blue - sane Nix"
