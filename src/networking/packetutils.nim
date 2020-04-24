proc readVarInt*(varInt: seq[byte]): int32 =
  for idx, b in varInt:
    var value: int32 = cast[int32](b and 127'u8)

    result = result or (value shl (7 * idx))

    if (b and 128'u8) == 0: break

proc writeVarInt*(inp: int32): seq[byte] =
  var input: int32 = inp

  while (input and -128'i32) != 0:
    result.add(cast[byte]((input and 127'i32) or 128'i32))

    input = input shr 7

  result.add(cast[byte](input))

proc readVarLong*(varLong: seq[byte]): int64 =
  for idx, b in varLong:
    var value: int64 = cast[int64](b and 127'u8)

    result = result or (value shl (7 * idx))

    if (b and 128'u8) == 0: break

proc writeVarLong*(inp: int64): seq[byte] =
  var input: int64 = inp

  while (input and -128'i64) != 0:
    result.add(cast[byte]((input and 127'i64) or 128'i64))

    input = input shr 7

  result.add(cast[byte](input))