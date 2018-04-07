import unittest
import colors

import images

suite "images":
  test "load column":
    let i = newImages("fs")
    let col0 = i.getPixelColumn("img_spin.bin", x=0, y=0, h=8)
    let col1 = i.getPixelColumn("img_spin.bin", x=1, y=0, h=8)
    check(col0 != col1)

  test "load out of range":
    let i = newImages("fs")
    echo i.getPixelColumn("img_spin.bin", x=149, y=4, h=8)
    
