
#import runepkg/models
import "../models.nim"
# import runepkg/database
import "../database.nim"

proc cmdSet*(configuration: RuneConfiguration, name: string, value: string) =
  configuration.setRuneValue(name, value)
