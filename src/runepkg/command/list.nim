
#import runepkg/models
import "../models.nim"
import "../database.nim"

proc cmdList*(configuration: RuneConfiguration) =
  for entry in configuration.getRunes():
    echo(entry)
