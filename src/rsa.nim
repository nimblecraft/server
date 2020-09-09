import openssl

proc BN_new*(): SslPtr {.cdecl, dynlib: DLLSSLName, importc.}
proc BN_clear*(a: SslPtr) {.cdecl, dynlib: DLLSSLName, importc.}

proc BN_set_word*(a: SslPtr, w: int32): cint {.cdecl, dynlib: DLLSSLName, importc.}
proc BN_get_word*(a: SslPtr): int32 {.cdecl, dynlib: DLLSSLName, importc.}

proc RSA_new*(): PRSA {.cdecl, dynlib: DLLSSLName, importc.}

proc RSA_generate_key_ex*(rsa: PRSA, bits: cint, e: SslPtr, cb: SslPtr): cint {.cdecl, dynlib: DLLSSLName, importc.}

proc i2d_RSA_PUBKEY*(rsa: PRSA, ppout: ptr cstring): cint {.cdecl, dynlib: DLLSSLName, importc.}

var
  rsa*: PRSA
  publicKeyDER*: cstring

proc generateKeyPair*() =
  var bn: SslPtr = BN_new()
  discard BN_set_word(bn, 3)

  rsa = RSA_new()
  discard RSA_generate_key_ex(rsa, 1024, bn, nil)

  echo i2d_RSA_PUBKEY(rsa, addr publicKeyDER)

  BN_clear(bn)