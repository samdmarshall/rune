# imports from standard library
##
import os
import parseopt2

# mark that we want to compile the companion "keychain.m" file as part of building this file.
# additionally, declare the interface that should be used to access the bridged code to run the 
# code that accesses the system APIs for the keychain
##
{.compile: "keychain.m", passL: "-framework Foundation -framework Security".}
proc getTokenFromKeychain(token_name: cstring, keychain_path: cstring): cstring {.importc.}

# define the usage for "--help"
##
proc usage =
  echo "usage: " & os.extractFilename(os.getAppFilename()) & " [--help|-h] [-v|--version] [-p|--keychain]:<keychain path> [-n|--name]:<item name>"

# define the version number
##
proc version_info =
  echo "secure-env v0.1"

# ===========================================
# this is the entry-point, there is no main()
# ===========================================

# define default values for the keychain path and name of the token
var keychain_path: string = ""
var secure_item_name: string = ""

# iterate over the command line flags passed to the executable
for kind, key, value in parseopt2.getopt():
  case kind
  of cmdLongOption, cmdShortOption:
    case key
    of "help", "h":
      usage()
    of "version", "v":
      version_info()
    of "keychain", "p":
      let expanded_path: string = os.expandTilde(value)
      keychain_path = os.expandFilename(expanded_path)
    of "name", "n":
      secure_item_name = value
    else: discard
  else: discard
  

# if the path specified by the keychain parameter exists and a string is given as the token name, then get it from the keychain.
##
if os.fileExists(keychain_path) and secure_item_name != "":
  let token_value = getTokenFromKeychain(secure_item_name, keychain_path)
  if token_value.len > 0:
    echo(token_value)
