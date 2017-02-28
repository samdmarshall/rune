# build

`nim compile secureEnv.nim`

# usage
this stores key-value pairs in a sqlite database that can be placed into version control or shared however. the secrets are encrypted/decrypted based on the values of the "encrypt_cmd" and "decrypt_cmd" that is set in the config file (`$XDG_CONFIG_HOME/secure-env/config.yml` or the `SECURE_ENV_CONFIG` environment variable). I am using gpg keys to do this, so my config looks like this:

```
---
database: ~/.config/storage/secure
encrypt: 
  cmd: "/usr/local/bin/gpg"
  args: ["--armor", "--recipient", "me@samdmarshall.com", "--encrypt"]
decrypt:
  cmd: "/usr/local/bin/gpg"
  args: ["--no-tty", "--quiet", "--decrypt"]
```

## commands

there are three commands:

* `get`: decrypts a secret with a given key name
  usage: `secure-env get --key:GITHUB_API_TOKEN`
* `set`: encrypts a secret with a given key name
  usage: `secure-env set --key:GITHUB_API_TOKEN --value:"hello world!"`
* `list`: lists all keys stored in the database
  usage: `secure-env list`

# installation

`brew tap samdmarshall/formulae`

`brew install samdmarshall/secure-env`


