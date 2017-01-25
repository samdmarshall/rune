# build

`nim compile --out:secure-env --app:console --passL:"-framework Foundation -framework Security" secureEnv.nim`

# usage
this was primarily made for my own usage, but it unlocks and retrieves items out of a keychain that is registered with the system. I store a bunch of API tokens for my shell in a shared keychain so it is always in sync (and retrieves the password out of my login keychain to unlock). this acts as a wrapper around making those calls instead of using shell scripting when setting up a new shell session (considerably slower).

# installation

`brew tap samdmarshall/formulae`

`brew install samdmarshall/secure-env`


