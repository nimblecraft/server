proc fromVarInt*(val: int): seq[byte] =
  var value: int = val

  while true:
    var temp: byte = cast[byte](value and 0b0111_1111)

    value = value shr 7

    if value != 0:
      temp = temp or 0b1000_0000

    result.add temp

    if value == 0: break

proc toVarInt*(bytes: seq[byte]): int =
  result = 0

  for idx, b in bytes:
    var value: int = cast[int](b and 0b0111_1111)

    result = result or (value shl (7 * idx))

    if (b and 0b1000_0000) == 0: break

proc fromVarLong*(val: int64): seq[byte] =
  var value: int64 = val

  while true:
    var temp: byte = cast[byte](value and 0b0111_1111)

    value = value shr 7

    if value != 0:
      temp = temp or 0b1000_0000

    result.add temp

    if value == 0: break

proc toVarLong*(bytes: seq[byte]): int64 =
  result = 0

  for idx, b in bytes:
    var value: int64 = cast[int64](b and 0b0111_1111)

    result = result or (value shl (7 * idx))

    if (b and 0b1000_0000) == 0: break