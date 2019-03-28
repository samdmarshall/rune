import os
import strutils
import parseopt2

import runepkg/lib

type SubCommand {.pure.} = enum
  None,
  Get,
  Set,
  List,
  Find

# get progname
##
proc progname(): string =
  return getAppFilename().extractFilename()

# define the usage for "--help"
##
proc usage(command: SubCommand) =
  case command:
  of SubCommand.None: echo("usage: " & progname() & " [--help|-h] [--version] [get|set|list|find] ...")
  of SubCommand.Get:  echo("usage: " & progname() & " get --key:<name of secret>")
  of SubCommand.Set:  echo("usage: " & progname() & " set --key:<name of secret> --value:<secret>")
  of SubCommand.List: echo("usage: " & progname() & " list")
  of SubCommand.Find: echo("usage: " & progname() & " find <*pattern*>")
  quit(QuitSuccess)

# define the version number
##
proc version_info =
  echo progname() & " v0.5.3"
  quit(QuitSuccess)

# ===========================================
# this is the entry-point, there is no main()
# ===========================================

let config_data = initConfiguration()

var current_command = SubCommand.None
var token_key = ""
var token_value = ""
var token_key_substring = ""
var parser = initOptParser()

for kind, key, value in parser.getopt():
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
    of "find": current_command = SubCommand.Find
    else:
      if current_command == SubCommand.Find:
        if token_key_substring.len == 0:
          token_key_substring = key
        else:
          echo("Error! The 'find' command only accepts one search parameter. You may need to put your search pattern in quotes if your shell is interpreting the argument instead.")
          quit(QuitFailure)
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
of SubCommand.Find:
  if token_key_substring.len == 0:
    usage(current_command)

  let prefix_search = token_key_substring.endsWith("*")
  let suffix_search = token_key_substring.startsWith("*")
  let full_search = (not prefix_search) and (not suffix_search)

  if prefix_search: token_key_substring.removeSuffix('*')
  if suffix_search: token_key_substring.removePrefix('*')

  let pattern = token_key_substring.toLowerAscii()
  if pattern.len == 0:
    echo("Error! Invalid pattern input, when using a prefix or suffix wildcard the seach pattern must be of non-zero length without it.")
    echo("  If you want to display all entries, use the 'list' command instead.")
    quit(QuitFailure)

  for entry in config_data.getRunes():
    let entry_name = entry.toLowerAscii()
    if prefix_search:
      if entry_name.startsWith(pattern): echo(entry)
    if suffix_search:
      if entry_name.endsWith(pattern): echo(entry)
    if full_search:
      if entry_name.contains(pattern): echo(entry)
else:
  discard

