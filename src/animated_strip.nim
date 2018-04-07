import tables
import sequtils
import colors
import options
import strformat

import types
import images

type AnimChannel = ref object of RootObj
    xStart: float
    xGoal: float
    start: Millis
    `end`: Millis
  
proc newAnimChannel(x: float): AnimChannel =
  new result
  result.xGoal = x
  result.start = Millis(0)
  result.end = Millis(0)

proc get(this: AnimChannel, now: Millis): float =
  ## now is assumed to never decrease.
  if now >= this.end:
    result = this.xGoal
  else:
    let dur = this.end - this.start
    result = (this.end - now) / dur * this.xStart +
                 (now - this.start) / dur * this.xGoal
  echo &"anim get now={now} start={this.start} end={this.end} -> {result}"

proc animateTo(this: AnimChannel, now: Millis, x: float,
               rate: float) =
  if this.xGoal == x:
    return
  this.start = now
  this.xStart = this.get(now)
  this.end = this.start + Millis(abs(x - this.xStart) / rate)
  this.xGoal = x
  
  
type
  # rdf version uses urls here, but the python layer can map them to
  # ints.
  GroupId* = distinct int

proc `==` (x, y: GroupId): bool {.borrow.}
proc `$` (x: GroupId): string {.borrow.}

type  
  Interp = enum
    slide, # move through the image to get to the new coordinates
    crossfade, # blend from start and end colors in rgb space

  ScanGroup = ref object of RootObj
    id: GroupId
    numLeds: int
    x: AnimChannel
    y: AnimChannel
    height: AnimChannel
    dir: Filename
    src: Filename
    srcGoal: Filename
    
  ScanGroupConfig* = tuple[id: GroupId, numLeds: int]
    
  
proc newScanGroup(dir: Filename, c: ScanGroupConfig): ScanGroup =
  new result
  result.dir = dir
  result.id = c.id
  result.numLeds = c.numLeds
  result.x = newAnimChannel(0)
  result.y = newAnimChannel(0)
  result.height = newAnimChannel(cast[float](c.numLeds)) 

proc currentColors(this: ScanGroup, now: Millis): seq[Color] =
  let img = newImages(this.dir)
  let col0 = img.getPixelColumn(Filename("img_knob.bin"),
                                toInt(this.x.get(now)),
                                toInt(this.y.get(now)),
                                this.numLeds)#toInt(this.height.get(now)))
  result = col0
  doAssert(result.len() == this.numLeds, &"result was {result.len}")

proc animateTo(this: ScanGroup,
               now: Millis,
               x, y, height: Option[float],
               src: Filename,
               rate: float,
               interpolate: Interp) =
  if isSome x: this.x.animateTo(now, x.get(), rate)
  if isSome y: this.y.animateTo(now, y.get(), rate)
  if isSome height: this.height.animateTo(now, height.get(), rate)
  this.srcGoal = src



type
  OutputStrip* = ref object of RootObj
    numLeds: int
    groups: seq[ScanGroup]
    dir: Filename

proc newOutputStrip*(numLeds: int, dir: Filename): OutputStrip =
  new result
  result.numLeds = numLeds
  result.dir = dir
  
proc setupGroups*(this: OutputStrip, groups: seq[ScanGroupConfig]) =
  this.groups = map(groups, proc (c: auto): auto = newScanGroup(this.dir, c))
  
proc groupById(this: OutputStrip, id: GroupId): ScanGroup =
  for sg in this.groups:
    if sg.id == id:
      return sg
  raise newException(KeyError, $(id))
  
proc animateTo*(this: OutputStrip, id: GroupId,
                now: Millis,
                x, y, height: Option[float],
                src: Filename,
                rate: float = 30.0/1000.0, # x/y/h units per milli
                interpolate: Interp = slide) =
  this.groupById(id).animateTo(now, x, y, height, src, rate,
                               interpolate)

proc updateOutput(this: OutputStrip) =
  discard
  
proc step*(this: OutputStrip, now: Millis) =
  this.updateOutput()

proc currentColors*(this: OutputStrip, now: Millis): seq[Color] =
  result = concat(map(this.groups,
                      proc(sg: auto): auto = currentColors(sg, now)))
