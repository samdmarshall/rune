import os
import strformat

import commandeer

import runepkg/[ defaults, configuration, models ]
import runepkg/command/[ find, get, set, list, usage, version ]

# =======================
# this is the entry-point
# =======================

proc main() =
  commandline:
    option setConfigurationPath, string, Flag_Long_Config, Flag_Short_Config, DefaultConfigPath
    subcommand Command_Get, ["get"]:
      option flagGetSecretName, string, Flag_Long_Key, Flag_Short_Key
      exitoption Flag_Long_Help, Flag_Short_Help, cmdUsage("get")
    subcommand Command_Set, ["set"]:
      option flagSetSecretName, string, Flag_Long_Key, Flag_Short_Key
      option flagSetSecretValue, string, Flag_Long_Value, Flag_Short_Value
      exitoption Flag_Long_Help, Flag_Short_Help, cmdUsage("set")
    subcommand Command_List, ["list"]:
      exitoption Flag_Long_Help, Flag_Short_Help, cmdUsage("list")
    subcommand Command_Find, ["find"]:
      argument NamePattern, string
      exitoption Flag_Long_Help, Flag_Short_Help, cmdUsage("find")
    exitoption Flag_Long_Help, Flag_Short_Help, cmdUsage("")
    exitoption Flag_Long_Version, Flag_Short_Version, cmdVersion()

  let conf_path = resolveConfigPath(setConfigurationPath, EnvVar_Config)
  if not fileExists(conf_path):
    echo(fmt"Unable to locate the configuration file, please create it at path: `{DefaultConfigPath}` or define `{EnvVar_Config}` with the path value in your shell environment.")
    quit(QuitFailure)

  let configuration = initConfiguration(conf_path)

  if Command_Get:
    cmdGet(configuration, flagGetSecretName)

  if Command_Set:
    cmdSet(configuration, flagSetSecretName, flagSetSecretValue)

  if Command_List:
    cmdList(configuration)

  if Command_Find:
    cmdFind(configuration, NamePattern)

  if not (Command_Find or Command_Get or Command_Set or Command_List):
    echo(cmdUsage(""))

when isMainModule:
  main()
