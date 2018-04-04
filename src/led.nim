import strutils
import strformat
import mgos

type
  mgos_app_init_result* {.size: sizeof(cint).} = enum
    MGOS_APP_INIT_ERROR = -2, MGOS_APP_INIT_SUCCESS = 0


#########

proc log(msg: string) =
  printf(msg & "\n")

log("hello nim")
  
proc mgos_app_init*(): mgos_app_init_result =
  return MGOS_APP_INIT_SUCCESS

type LedPlayback {.exportc.} = object of RootObj
  pin: cint
  numPixels: cint
  filename: cstring
  img_fd: cint

proc newLedPlayback*(pin: cint, numPixels: cint): ref LedPlayback {.exportc.} =
  result.new()
  result.pin = pin
  result.numPixels = numPixels
  result.filename = nil
  discard mgos_gpio_set_mode(pin, MGOS_GPIO_MODE_OUTPUT)

proc openFile(this: var LedPlayback, filename: cstring) =
  if this.filename != nil:
    if mgos_vfs_close(this.img_fd) > 0:
      return

  this.img_fd = mgos_vfs_open(filename, O_RDONLY, 0)
  this.filename = filename

proc playImage*(this: var LedPlayback, filename: cstring) {.exportc.} =
  this.openFile(filename)
  let n = this.numPixels * 3
  log(fmt"n = {n}")

  var buf = newSeq[uint8](n)

  var frames = 0
  while mgos_vfs_read(this.img_fd, buf[0].addr, buf.len) > 0:
    mgos_gpio_write(this.pin, false)
    mgos_usleep(60)
    mgos_bitbang_write_bits(this.pin, MGOS_DELAY_100NSEC,
                            3, 8, 8, 6,
                            buf[0].addr,
                            buf.len)
    mgos_gpio_write(this.pin, false)
    mgos_usleep(60)
    mgos_gpio_write(this.pin, true)

    mgos_usleep(33000'u32)
    inc frames
    if frames > 10:
       break


