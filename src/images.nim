import ospaths
import colors
import strformat
import thermlog
import types

when hostOS != "standalone":
  type PlatformFile = ref object of RootObj
    f: File

  proc openPlatformFile(fn: string): PlatformFile =
    new result
    result.f = open(fn)

  proc setFilePos(this: PlatformFile, pos: int) = this.f.setFilePos(pos)
  proc readBytes(this: PlatformFile, a: var openArray[int8|uint8], len: Natural): int =
    return this.f.readBytes(a, 0, len)
  proc close(this: PlatformFile) = this.f.close()
else:
  import mgos
  type PlatformFile = ref object of RootObj
    fd: cint
  proc openPlatformFile(fn: string): PlatformFile =
    new result
    result.fd = mgos_vfs_open(fn, O_RDONLY, 0)
  proc setFilePos(this: PlatformFile, pos: int) =
    discard mgos_vfs_lseek(this.fd, cast[cint](pos), SEEK_SET)
  proc readBytes(this: PlatformFile, a: var openArray[int8|uint8], len: Natural): int =
    return mgos_vfs_read(this.fd, a.addr, cast[csize](len))
  proc close(this: PlatformFile) =
    discard mgos_vfs_close(this.fd)

    
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
  log("openfile " & ($(this.dir) / $(path)))    
  var f = openPlatformFile($(this.dir) / $(path))
  defer: close(f)

  let pos = (fh * x + y) * 3
  f.setFilePos(pos)

  var buf = newSeq[uint8](h * 3)
  let nread = f.readBytes(buf, h * 3)
  if nread != h * 3:
    raise newException(IOError, $(path))

  result = newSeq[Color](h)
  for i in 0..<h:
    result[i] = rgb(buf[i * 3 + 0],
                    buf[i * 3 + 1],
                    buf[i * 3 + 2])

