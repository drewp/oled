import strutils
import strformat
import mgos
import colors
import thermlog
import types
import animated_strip

type
  mgos_app_init_result* {.size: sizeof(cint).} = enum
    MGOS_APP_INIT_ERROR = -2, MGOS_APP_INIT_SUCCESS = 0


#########

log("hello nim")
  
proc mgos_app_init*(): mgos_app_init_result =
  return MGOS_APP_INIT_SUCCESS

type LedPlayback {.exportc.} = object of RootObj
    pin: cint
    numPixels: cint
    strip: OutputStrip
  
proc newLedPlayback*(pin: cint, numPixels: cint, imageDir: cstring): ref LedPlayback {.exportc.} =
  result.new()
  result.pin = pin
  discard mgos_gpio_set_mode(pin, MGOS_GPIO_MODE_OUTPUT)
  log("strip")
  result.strip = newOutputStrip(numPixels, Filename(cast[string](imageDir)))
  result.strip.setupGroups(@[(id: GroupId(1), numLeds: cast[int](numPixels))])
  log("new strip")
  
  
proc playImage*(this: var LedPlayback, filename: cstring) {.exportc.} =
  let now = Millis(0)
  let cols = this.strip.currentColors(now)
  var buf = newSeq[uint8](len(cols) * 3)

  for i in 0..<len(cols):
    let rgb = extractRGB(cols[i])
    buf[i * 3 + 0] = rgb[0]
    buf[i * 3 + 1] = rgb[1]
    buf[i * 3 + 2] = rgb[2]

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



