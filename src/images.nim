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
  echo &"get at {x} {y} {h}"
  let
    x = x.clamp(0, fw - 1)
    y = y.clamp(0, fh - h.clamp(0, fh))
    h = h.clamp(0, fh)
    
  var f = open($(this.dir) / $(path))
  defer: close f

  let pos = (fh * x + y) * 3
  f.setFilePos(pos)
  echo "read at ", pos
  var buf = alloc(h * 3 + 1)
  let nread = f.readBuffer(buf, h * 3)
  if nread != h * 3:
    raise newException(IOError, $(path))
  let bufInts = cast[seq[uint8]](buf)
  #bufInts.setLen(h * 3)
  #echo &"bufInts = {bufInts}"
  result = newSeq[Color](h)
  for i in 0..<h:
    result[i] = rgb(bufInts[i * 3 + 0],
                    bufInts[i * 3 + 1],
                    bufInts[i * 3 + 2])
    echo &"build result[{i}] from {bufInts[i * 3 + 0]} {result[i]}"
  
  dealloc(buf)
  echo &"returning {result.len} of h={h}"
