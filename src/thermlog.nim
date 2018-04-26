import strutils
import strformat
import mgos

proc log*(msg: string) =
  printf(msg & "\n")
