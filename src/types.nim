
type Millis* = distinct int
proc `+` *(x, y: Millis): Millis {.borrow.}
proc `-` *(x, y: Millis): Millis {.borrow.}
proc `<` *(x, y: Millis): bool {.borrow.}
proc `<=` *(x, y: Millis): bool {.borrow.}
proc `/` *(x, y: Millis): float {.borrow.}
proc `$` *(x: Millis): string {.borrow.}

type Filename* = distinct string
proc `$` *(x: Filename): string {.borrow.}
