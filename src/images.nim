import os
import ospaths
import colors
import strformat

import types

type Images = ref object of RootObj
  dir: Filename

proc newImages*(dir: Filename): Images =
  new result
  result.dir = dir

proc getPixelColumn*(this: Images, path: Filename,
                     x, y, h: int): seq[Color] =
  let fw = 150
  let fh = 8

  let
    x = x.clamp(0, fw - 1)
    y = y.clamp(0, fh - h.clamp(0, fh))
    h = h.clamp(0, fh)
    
  var f = open($(this.dir) / $(path))
  defer: close f

  let pos = (fh * x + y) * 3
  f.setFilePos(pos)

  var buf = newSeq[uint8](h * 3)
  let nread = f.readBytes(buf, 0, h * 3)
  if nread != h * 3:
    raise newException(IOError, $(path))

  result = newSeq[Color](h)
  for i in 0..<h:
    result[i] = rgb(buf[i * 3 + 0],
                    buf[i * 3 + 1],
                    buf[i * 3 + 2])

