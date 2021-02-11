
import os
import osproc
import strutils
import db_sqlite
import algorithm

# import runepkg/models
import "models.nim"

proc encryptData*(config_data: RuneConfiguration, input: string): string {.gcsafe.} =
  let encryption_process = startProcess(config_data.encrypt.cmd, "", config_data.encrypt.args)

  let input_handle = encryption_process.inputHandle()
  let output_handle = encryption_process.outputHandle()

  var output_file: File
  discard open(output_file, output_handle, fmRead)

  var input_file: File
  if open(input_file, input_handle, fmWrite):
    write(input_file, input)
    input_file.close()

  let output = output_file.readAll().string

  var output_data: seq[string] = newSeq[string]()
  for data_char in output:
    output_data.add($ord(data_char))
  encryption_process.close()

  result = output_data.join(":")

proc decryptData*(config_data: RuneConfiguration, input: string): string {.gcsafe.} =
  let decryption_process = startProcess(config_data.decrypt.cmd, "", config_data.decrypt.args)

  let input_handle = decryption_process.inputHandle()
  let output_handle = decryption_process.outputHandle()

  var output_file: File
  discard open(output_file, output_handle, fmRead)

  var input_file: File
  if open(input_file, input_handle, fmWrite):
    for byte_rep in input.split(":"):
      let hex_byte_int = byte_rep.parseUInt()
      let hex_byte = chr(hex_byte_int)
      write(input_file, hex_byte)
    input_file.close()

  result = output_file.readAll().string
  decryption_process.close()

proc openRuneDB(config_data: RuneConfiguration): DbConn =
  let database_path = expandTilde(config_data.database)
  result = open(database_path, "", "", "")
  result.exec(sql"CREATE TABLE IF NOT EXISTS vault (id INTEGER PRIMARY KEY, key TEXT, value BLOB)")

proc getRune*(config: RuneConfiguration, token_key: string): string =
  let secure_db = config.openRuneDB()
  let encrypted_value = secure_db.getValue(sql"SELECT value FROM vault WHERE key = ?", token_key)
  secure_db.close()
  result = decryptData(config, encrypted_value)

proc setRuneValue*(config: RuneConfiguration, token_key: string, token_value: string) =
  let secure_db = config.openRuneDB()
  if token_value.len == 0:
    secure_db.exec(sql"DELETE FROM vault WHERE key = ?", token_key)
  else:
    let exists = secure_db.getValue(sql"SELECT id FROM vault WHERE key = ?", token_key)
    let encrypted_value = encryptData(config, token_value)
    if exists.len > 0:
      secure_db.exec(sql"UPDATE vault SET value = ? WHERE key = ?", $encrypted_value, token_key)
    else:
      discard secure_db.insertID(sql"INSERT INTO vault(key, value) VALUES (?, ?)", token_key, encrypted_value)
  secure_db.close()

proc getRunes*(config: RuneConfiguration): seq[string] =
  let secure_db = config.openRuneDB()
  for row in secure_db.fastRows(sql"SELECT id,key FROM vault"):
    result.add(row[1])
  secure_db.close()
  result.sort(cmpIgnoreCase)
