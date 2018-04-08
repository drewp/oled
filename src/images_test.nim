import unittest
import colors

import types
import images

suite "images":
  test "load column":
    let i = newImages(Filename("fs"))
    let col0 = i.getPixelColumn(Filename("img_spin.bin"), x=0, y=0, h=8)
    let col1 = i.getPixelColumn(Filename("img_spin.bin"), x=1, y=0, h=8)
    check(col0 != col1)

  test "load out of range":
    let i = newImages(Filename("fs"))
    echo i.getPixelColumn(Filename("img_spin.bin"), x=149, y=4, h=8)
    
