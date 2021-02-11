

type
  ShellCommand* = object
    cmd*: string
    args*: seq[string]

  RuneConfiguration* = object
    database*: string
    encrypt*: ShellCommand
    decrypt*: ShellCommand
