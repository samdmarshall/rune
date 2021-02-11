# rune


## build

`nimble build`

## usage
this stores key-value pairs in a sqlite database that can be placed into version control or shared however. the secrets are encrypted/decrypted based on the values of the "encrypt_cmd" and "decrypt_cmd" that is set in the config file (`$XDG_CONFIG_HOME/rune/config.toml` or the `RUNE_CONFIG` environment variable). I am using gpg keys to do this, so my config looks like this:

```
[database]
path = "~/.config/storage/secure"

[encrypt]
cmd = "/usr/local/bin/gpg"
args = ["--armor", "--recipient", "hello@example.com", "--encrypt"]

[decrypt]
cmd = "/usr/local/bin/gpg"
args = ["--no-tty", "--quiet", "--decrypt"]
```

### commands

there are four commands:

* `get`: decrypts a secret with a given key name
  usage: `rune get --key:GITHUB_API_TOKEN`
* `set`: encrypts a secret with a given key name
  usage: `rune set --key:GITHUB_API_TOKEN --value:"hello world!"`
* `list`: lists all keys stored in the database
  usage: `rune list`
* `find`: allows for glob-pattern search for saved secrets
  usage: `rune find *_TOKEN`

## installation

### Homebrew Tap

`brew install samdmarshall/formulae/rune`


### Build from Source

```
$ nimble build
$ nimble install
```
