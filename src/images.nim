import os
import ospaths
import colors
import strformat

type Images = ref object of RootObj
  dir: string

proc newImages*(dir: string): Images =
  new result
  result.dir = dir

proc getPixelColumn*(this: Images, path: string,
                     x, y, h: int): seq[Color] =
  var f: File
  if not f.open(this.dir / path):
    raise newException(IOError, path)
  let fw = 150
  let fh = 8
  echo &"get at {x} {y} {h}" 
  f.setFilePos((fh * x + y) * 3)
  echo "read at", (fh * x + y) * 3
  var buf = alloc(fw)
  let nread = f.readBuffer(buf, h * 3)
  if nread != h * 3:
    raise newException(IOError, path)
  result = newSeq[Color](h)
  let bufInts = cast[seq[uint8]](buf)
  for i in 0..<h:
    result[i] = rgb(bufInts[i * 3 + 0],
                    bufInts[i * 3 + 1],
                    bufInts[i * 3 + 2])
  
  dealloc(buf)
  f.close()
