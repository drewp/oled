import unittest
import colors
import options

import animated_strip

suite "animated_strip":
  test "setup groups":
    let s = newOutputStrip(numLeds=30)
    
    s.setupGroups(@[(id: GroupId(1), numLeds: 10),
                    (id: GroupId(2), numLeds: 20)])

  test "get color":
    let s = newOutputStrip(numLeds=2)
    s.setupGroups(@[(id: GroupId(1), numLeds: 2)])
    check:
      s.currentColors(now=Millis(0)) == @[rgb(0, 0, 0), rgb(0, 0, 0)]
    
  test "animate":
    let s = newOutputStrip(numLeds=1)
    s.setupGroups(@[(id: GroupId(1), numLeds: 1)])
    var now = Millis(0)
    s.animateTo(GroupId(1), now,
                x=none(float), y=some(5.0), height=none(float),
                src=Filename("demo.img"))
    check(s.currentColors(now) == @[rgb(0, 0, 0)])
    s.step(now)
    now = Millis(30000)
    check(s.currentColors(now) == @[rgb(2, 0, 0)])
    
