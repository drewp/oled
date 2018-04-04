const O_RDONLY*: cint = 0
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

proc printf*(fmt: cstring) {.importc: "mgos_cd_printf", varargs, header: "mgos_core_dump.h".}
