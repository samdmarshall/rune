import os
import parseopt2

import runepkg/lib

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
  echo progname() & " v0.5.2"
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
