import unittest
import colors
import options

import types
import animated_strip

suite "animated_strip":
  test "setup groups":
    let s = newOutputStrip(numLeds=30, dir=Filename("fs"))
    
    s.setupGroups(@[(id: GroupId(1), numLeds: 10),
                    (id: GroupId(2), numLeds: 20)])

  test "get color":
    let s = newOutputStrip(numLeds=2, dir=Filename("fs"))
    s.setupGroups(@[(id: GroupId(1), numLeds: 2)])
    check:
      s.currentColors(now=Millis(0)) == @[rgb(0, 0, 0), rgb(0, 0, 0)]
    
  test "animate":
    let s = newOutputStrip(numLeds=1, dir=Filename("fs"))
    s.setupGroups(@[(id: GroupId(1), numLeds: 1)])
    var now = Millis(0)
    s.animateTo(GroupId(1), now,
                x=some(10.0), y=none(float), height=none(float),
                src=Filename("demo.img"),
                rate=1)
    check(s.currentColors(now) == @[rgb(0, 0, 0)])
    s.step(now)
    now = Millis(1)
    check(s.currentColors(now) == @[rgb(2, 0, 0)])
    
