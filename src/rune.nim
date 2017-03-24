# imports from standard library
##
import os
import yaml
import osproc
import streams
import strutils
import db_sqlite

type ShellCommand* = object
  cmd*: string
  args*: seq[string]

type RuneConfiguration* = object
  database*: string
  encrypt*: ShellCommand
  decrypt*: ShellCommand

proc encryptData*(config_data: RuneConfiguration, input: string): string {.gcsafe.} =
  let encryption_process = startProcess(config_data.encrypt.cmd, "", config_data.encrypt.args)

  let input_handle = encryption_process.inputHandle()
  let output_handle = encryption_process.outputHandle()

  var output_file: File
  discard open(output_file, output_handle, fmRead)
    
  var input_file: File
  if open(input_file, input_handle, fmWrite):
    write(input_file, input)
    input_file.close()

  let output = output_file.readAll().string
  
  var output_data: seq[string] = newSeq[string]()
  for data_char in output:
    output_data.add($ord(data_char))
  encryption_process.close()

  return strutils.join(output_data, ":")
  
proc decryptData*(config_data: RuneConfiguration, input: string): string {.gcsafe.} =
  let decryption_process = startProcess(config_data.decrypt.cmd, "", config_data.decrypt.args)
  
  let input_handle = decryption_process.inputHandle()
  let output_handle = decryption_process.outputHandle()

  var output_file: File
  discard open(output_file, output_handle, fmRead)
  
  var input_file: File
  if open(input_file, input_handle, fmWrite):
    for byte_rep in input.split(":"):
      let hex_byte_int = byte_rep.parseUInt()
      let hex_byte = chr(hex_byte_int)
      write(input_file, hex_byte)
    input_file.close()

  let output = output_file.readAll().string
  decryption_process.close()

  return output

proc initConfiguration*(): RuneConfiguration {.gcsafe.} =
  var config_data: RuneConfiguration
  
  let default_prefs_path = expandTilde("~/.config/rune/config.yml")
  let alternative_prefs_path = getEnv("RUNE_CONFIG")
  
  let use_alternative_config_path: bool = existsEnv("RUNE_CONFIG") and alternative_prefs_path.len > 0
  
  let load_prefs_path: string = 
    if use_alternative_config_path: alternative_prefs_path
    else: default_prefs_path

  if not os.existsFile(load_prefs_path):
    echo("Unable to locate the config file, please create it at `~/.config/rune/config.yml` or define `RUNE_CONFIG` in your environment")
    quit(QuitFailure)

  let config_stream = newFileStream(load_prefs_path)
  yaml.serialization.load(config_stream, config_data)
  config_stream.close()

  return config_data

proc openRuneDB(config_data: RuneConfiguration): DbConn =
  let database_path = expandTilde(config_data.database)
  let secure_db = open(database_path, nil, nil, nil)
  secure_db.exec(sql"CREATE TABLE IF NOT EXISTS vault (id INTEGER PRIMARY KEY, key TEXT, value BLOB)")
  return secure_db

proc getRune*(config: RuneConfiguration, token_key: string): string =
  let secure_db = config.openRuneDB()
  let encrypted_value = secure_db.getValue(sql"SELECT value FROM vault WHERE key = ?", token_key)
  secure_db.close()
  return decryptData(config, encrypted_value)

proc setRuneValue*(config: RuneConfiguration, token_key: string, token_value: string): void =
  let secure_db = config.openRuneDB()
  if token_value.len == 0:
    secure_db.exec(sql"DELETE FROM vault WHERE key = ?", token_key)
  else:
    let exists = secure_db.getValue(sql"SELECT id FROM vault WHERE key = ?", token_key)
    let encrypted_value = encryptData(config, token_value)
    if exists.len > 0:
      secure_db.exec(sql"UPDATE vault SET value = ? WHERE key = ?", $encrypted_value, token_key)
    else:
      discard secure_db.insertID(sql"INSERT INTO vault(key, value) VALUES (?, ?)", token_key, encrypted_value)
  secure_db.close()

proc getRunes*(config: RuneConfiguration): seq[string] =
  let secure_db = config.openRuneDB()
  var items = newSeq[string]()
  for row in secure_db.fastRows(sql"SELECT id,key FROM vault"):
    items.add(row[1])
  secure_db.close()
  return items

when isMainModule:
  import parseopt2

  type SubCommand {.pure.} = enum
    None,
    Get,
    Set,
    List,
  
  # get progname
  ##
  proc progname(): string =
    return getAppFilename().extractFilename()

  # define the usage for "--help"
  ##
  proc usage(command: SubCommand) =
    case command:
    of SubCommand.None: echo("usage: " & progname() & " [--help|-h] [--version] [get|set|list] ...")
    of SubCommand.Get:  echo("usage: " & progname() & " get --key:<name of secret>")
    of SubCommand.Set:  echo("usage: " & progname() & " set --key:<name of secret> --value:<secret>")
    of SubCommand.List: echo("usage: " & progname() & " list")
    quit(QuitSuccess)

  # define the version number
  ##
  proc version_info =
    echo progname() & " v0.4"
    quit(QuitSuccess)

  # ===========================================
  # this is the entry-point, there is no main()
  # ===========================================
  
  let config_data = initConfiguration()

  var current_command = SubCommand.None
  var token_key: string = ""
  var token_value: string = ""
  
  for kind, key, value in getopt():
    case kind
    of cmdLongOption, cmdShortOption:
      case key
      of "version": version_info()
      of "help", "h": usage(current_command)
      else:
        case current_command
        of SubCommand.Get:
          case key
          of "key": token_key = value
          else: discard
        of SubCommand.Set:
          case key
          of "key": token_key = value
          of "value": token_value = value
          else: discard
        else: discard
    of cmdArgument:
      case key:
      of "get":  current_command = SubCommand.Get
      of "set":  current_command = SubCommand.Set
      of "list": current_command = Subcommand.List
      else: discard
    else: discard
  
  case current_command
  of SubCommand.None:
    echo("please specify a subcommand! (run `rune --help` for more information)")
  of SubCommand.Get:
    echo(config_data.getRune(token_key))
  of SubCommand.Set:
    config_data.setRuneValue(token_key, token_value)
  of SubCommand.List:
    for item in config_data.getRunes():
      echo(item)
