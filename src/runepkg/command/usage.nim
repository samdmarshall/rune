
import strutils
import strformat

# import runepkg/defaults
import "../defaults.nim"

proc cmdUsage*(section: string = ""): string =
  var msg = newSeq[string]()
  case section
  of "get":
    msg.add fmt"usage: {NimblePkgName} get --key:<name of secret>"
  of "set":
    msg.add fmt"usage: {NimblePkgName} set --key:<name of secret> --value:<secret>"
  of "find":
    msg.add fmt"usage: {NimblePkgName} find <pattern>"
  of "list":
    msg.add fmt"usage: {NimblePkgName} list"
  else:
    msg.add fmt"usage: {NimblePkgName} [-h|--help] [--version] [-c|--config <path>] [get|set|list|find] ..."
  result = msg.join("\n")
