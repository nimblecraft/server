import endians

proc readVarInt*(varInt: seq[byte]): tuple[value: int, bytesNum: int] =
  for idx, b in varInt:
    inc result[1]
    var value: int32 = cast[int32](b and 127'u8)

    result[0] = result[0] or (value shl (7 * idx))

    if (b and 128'u8) == 0: break

proc writeVarInt*(inp: int): seq[byte] =
  var input: int32 = cast[int32](inp)

  while (input and -128'i32) != 0:
    result.add(cast[byte]((input and 127'i32) or 128'i32))

    input = input shr 7

  result.add(cast[byte](input))

proc readVarLong*(varLong: seq[byte]): tuple[value: int64, bytesNum: int] =
  for idx, b in varLong:
    inc result[1]
    var value: int64 = cast[int64](b and 127'u8)

    result[0] = result[0] or (value shl (7 * idx))

    if (b and 128'u8) == 0: break

proc writeVarLong*(inp: int64): seq[byte] =
  var input: int64 = inp

  while (input and -128'i64) != 0:
    result.add(cast[byte]((input and 127'i64) or 128'i64))

    input = input shr 7

  result.add(cast[byte](input))

proc writeString*(str: string): seq[byte] =
  var length = writeVarInt(cast[int32](str.len))
  result.add(length)

  for c in str:
    result.add(cast[byte](c))

proc writeUnsignedShort*(val: uint16): seq[byte] =
    result.add(cast[byte]((val shr 8) and 0b1111_1111))
    result.add(cast[byte](val and 0b1111_1111))

proc bigEndianUnsignedShort*(short: uint16): uint16 =
  var cpy = result
  bigEndian16(addr result, addr cpy)

proc bigEndianSignedShort*(short: int16): int16 =
  var cpy = result
  bigEndian16(addr result, addr cpy)