import strutils
import strformat

type
  mgos_app_init_result* {.size: sizeof(cint).} = enum
    MGOS_APP_INIT_ERROR = -2, MGOS_APP_INIT_SUCCESS = 0

const O_RDONLY: cint = 0
type
  mgos_gpio_mode* {.size: sizeof(cint).} = enum
    MGOS_GPIO_MODE_INPUT = 0, MGOS_GPIO_MODE_OUTPUT = 1, MGOS_GPIO_MODE_OUTPUT_OD = 2

type
  mgos_gpio_pull_type* {.size: sizeof(cint).} = enum
    MGOS_GPIO_PULL_NONE = 0,    ##  floating
    MGOS_GPIO_PULL_UP = 1, MGOS_GPIO_PULL_DOWN = 2

type
  mgos_gpio_int_mode* {.size: sizeof(cint).} = enum
    MGOS_GPIO_INT_NONE = 0, MGOS_GPIO_INT_EDGE_POS = 1, ##  positive edge
    MGOS_GPIO_INT_EDGE_NEG = 2, ##  negative edge
    MGOS_GPIO_INT_EDGE_ANY = 3, ##  any edge - positive or negative
    MGOS_GPIO_INT_LEVEL_HI = 4, ##  high voltage level
    MGOS_GPIO_INT_LEVEL_LO = 5

proc mgos_gpio_set_mode*(pin: cint; mode: mgos_gpio_mode): bool {. importc: "mgos_gpio_set_mode", header: "mgos_gpio.h".}

proc mgos_gpio_set_pull*(pin: cint; pull: mgos_gpio_pull_type): bool {. importc: "mgos_gpio_set_pull", header: "mgos_gpio.h".}

proc mgos_gpio_read*(pin: cint): bool {.importc: "mgos_gpio_read", header: "mgos_gpio.h".}

proc mgos_gpio_write*(pin: cint; level: bool) {.importc: "mgos_gpio_write", header: "mgos_gpio.h".}

proc mgos_vfs_open*(filename: cstring; flags: cint; mode: cint): cint {. importc: "mgos_vfs_open", header: "mgos_vfs.h".}

proc mgos_vfs_close*(vfd: cint): cint {.importc: "mgos_vfs_close", header: "mgos_vfs.h".}
proc mgos_vfs_read*(vfd: cint; dst: pointer; len: csize): csize {. importc: "mgos_vfs_read", header: "mgos_vfs.h".}
proc mgos_usleep*(usecs: uint32) {.importc: "mgos_usleep", header: "mgos_system.h".}

type
    mgos_delay_unit* {.size: sizeof(cint).} = enum
      MGOS_DELAY_MSEC = 0, MGOS_DELAY_USEC = 1, MGOS_DELAY_100NSEC = 2


proc mgos_bitbang_write_bits*(gpio: cint; delay_unit: mgos_delay_unit; t0h: cint;
                              t0l: cint; t1h: cint; t1l: cint; data: ptr uint8;
                              len: csize) {.importc: "mgos_bitbang_write_bits", header: "mgos_bitbang.h".}

proc printf(fmt: cstring) {.importc: "mgos_cd_printf", varargs, header: "mgos_core_dump.h".}

#########

proc log(msg: string) =
  printf(msg & "\n")

log("hello nim")
  
proc mgos_app_init*(): mgos_app_init_result =
  return MGOS_APP_INIT_SUCCESS

type
  led_playback {.exportc.} = object
    pin: cint
    numPixels: cint
    filename: cstring
    img_fd: cint

var g_led_playback*: led_playback

proc led_init*(pin: cint; numPixels: cint) {.exportc.} =
  g_led_playback.pin = pin
  g_led_playback.numPixels = numPixels
  g_led_playback.filename = nil

proc led_open_file(filename: cstring) =
  if g_led_playback.filename != nil:
    if mgos_vfs_close(g_led_playback.img_fd) > 0:
      return

  g_led_playback.img_fd = mgos_vfs_open(filename, O_RDONLY, 0)
  g_led_playback.filename = filename

proc play_led_image*(filename: cstring) {.exportc.} =
  led_open_file(filename)
  let n = g_led_playback.numPixels * 3
  log(fmt"n = {n}")

  var buf = newSeq[uint8](n)

  while mgos_vfs_read(g_led_playback.img_fd, buf[0].addr, buf.len) > 0:
    mgos_gpio_write(g_led_playback.pin, false)
    mgos_usleep(60)
    mgos_bitbang_write_bits(g_led_playback.pin, MGOS_DELAY_100NSEC,
                            3, 8, 8, 6,
                            buf[0].addr,
                            buf.len)
    mgos_gpio_write(g_led_playback.pin, false)
    mgos_usleep(60)
    mgos_gpio_write(g_led_playback.pin, true)

    mgos_usleep(33000'u32)


