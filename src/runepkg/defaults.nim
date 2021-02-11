
import os

const
  NimblePkgName* {.strdefine.} = ""
  NimblePkgVersion* {.strdefine.} = ""

  Flag_Long_Help* = "help"
  Flag_Short_Help* = "h"

  Flag_Long_Version* = "version"
  Flag_Short_Version* = ""

  Flag_Long_Config* = "config"
  Flag_Short_Config* = "c"
  DefaultConfigPath* = getConfigDir() / NimblePkgName / "config.toml"
  EnvVar_Config* = "RUNE_CONFIG"

  Flag_Long_Key* = "key"
  Flag_Short_Key* = ""

  Flag_Long_Value* = "value"
  Flag_Short_Value* = ""

  