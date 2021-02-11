
#import runepkg/models
import "../models.nim"
# import runepkg/database
import "../database.nim"

proc cmdGet*(configuration: RuneConfiguration, name: string) =
  let output = configuration.getRune(name)
  echo(output)
