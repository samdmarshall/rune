
import strformat

# import runepkg/defaults
import "../defaults.nim"

proc cmdVersion*(): string =
  result = fmt"{NimblePkgName} v{NimblePkgVersion}"
