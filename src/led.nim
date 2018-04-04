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

type
  led_playback {.exportc.} = object
    pin: cint
    numPixels: cint
    filename: cstring
    img_fd: cint

var g_led_playback*: led_playback

proc led_init*(pin: cint; numPixels: cint) {.exportc.} =
  discard mgos_gpio_set_mode(pin, MGOS_GPIO_MODE_OUTPUT)
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

  var frames = 0
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
    frames += 1
    if frames > 10:
       break


