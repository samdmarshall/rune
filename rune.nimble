# Package

version       = "0.5.5"
author        = "Samantha Marshall"
description   = "library to securely store secrets"
license       = "BSD 3-Clause"

srcDir = "src/"
binDir = "build/"
bin = @["rune"]
installExt = @["nim"]

# Dependencies

requires "nim >= 0.19.0"

requires "parsetoml"
requires "commandeer"
requires "db_connector"
