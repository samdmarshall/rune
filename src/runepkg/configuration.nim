
import os

import parsetoml

#import runepkg/[ models, defaults ]
import "defaults.nim"
import "models.nim"

proc resolveConfigPath*(path: string, envvar: string): string =
  result = path
  if existsEnv(envvar):
    let envvar_path = getEnv(envvar)
    if envvar_path.len > 0:
      result = envvar_path

proc parseArrayValue(settings: TomlTableRef, section: string, key: string): seq[string] =
  let entry = settings[section].tableVal
  let values = entry[key].arrayVal
  for value in values:
    let value_string = value.stringVal
    result.add(value_string)

proc parseStringValue(settings: TomlTableRef, section: string, key: string): string =
  let entry = settings[section].tableVal
  result = entry[key].stringVal

proc initConfiguration*(path: string): RuneConfiguration =
  let config: TomlTableRef = parseFile(path).getTable()
  result.database = expandTilde(config.parseStringValue("database", "path"))
  result.encrypt = ShellCommand(cmd: config.parseStringValue("encrypt", "cmd"), args: config.parseArrayValue("encrypt", "args"))
  result.decrypt = ShellCommand(cmd: config.parseStringValue("decrypt", "cmd"), args: config.parseArrayValue("decrypt", "args"))
  # result = RuneConfiguration(database: database_path, encrypt: encrypt_cmd, decrypt: decrypt_cmd)
