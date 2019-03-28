# Package

version       = "0.3.0"
author        = "Samantha Marshall"
description   = "library to securely store secrets"
license       = "BSD 3-Clause"

srcDir = "src/"
bin = @["rune"]
installExt = @["nim"]

# Dependencies

requires "nim >= 0.16.1"
requires "parsetoml"
