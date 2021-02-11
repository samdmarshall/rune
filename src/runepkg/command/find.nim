
import strutils

# import runepkg/models
import "../models.nim"
# import runepkg/database
import "../database.nim"

proc cmdFind*(configuration: RuneConfiguration, name: string) =
  var token_key_substring = name

  let prefix_search = token_key_substring.endsWith("*")
  let suffix_search = token_key_substring.startsWith("*")
  let full_search = (not prefix_search) and (not suffix_search)

  if prefix_search:
    token_key_substring.removeSuffix('*')
  if suffix_search:
    token_key_substring.removePrefix('*')

  let pattern = token_key_substring.toLowerAscii()
  if pattern.len == 0:
    echo("Error! Invalid pattern input, when using a prefix or suffix wildcard the seach pattern must be of non-zero length without it.")
    echo("  If you want to display all entries, use the 'list' command instead.")
    quit(QuitFailure)
  else:
    for entry in configuration.getRunes():
      let entry_name = entry.toLowerAscii()
      if prefix_search:
        if entry_name.startsWith(pattern):
          echo(entry)
      if suffix_search:
        if entry_name.endsWith(pattern):
          echo(entry)
      if full_search:
        if entry_name.contains(pattern):
          echo(entry)
