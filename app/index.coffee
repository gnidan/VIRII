$ = require 'jqueryify2'

Paper = require 'lib/paper'
Cell = require 'models/cell'
Virus = require 'models/virus'
World = require 'models/world'
Minigame = require('views/minigame').minigame
colors = require('views/minigame').colors

Effects = require 'lib/effects'

hitOptions =
  segments: true
  stroke: true
  fill: true
  tolerance: 5

class App
  constructor: ->

  render: ->
    canvas = $('#game')[0]

    Paper.setup(canvas)

    cellLayer = new Paper.Layer()
#    cellLayer.activate()
    
    introducedVirus = false

    randomColor = () ->
      colorIdx = Math.floor(Math.random() * colors.length)
      colors[colorIdx]

    lock = []
    for i in [0..3]
      color = randomColor()
      lock[i] = color

    w = new World(canvas)
    c1 = new Cell new Paper.Point(500, 400), w,
      lock: lock

    w.add c1

    frameTimes = []
    text = new Paper.PointText(new Paper.Point(20, 20))
    text.characterStyle.fontSize = 20

    time = 0

    scrolling = null
    scrollMagnitude = null

    scrollTime = 0
    Paper.view.onFrame = (event) ->
      if frameTimes.length > 60
        frameTimes = frameTimes.slice(1)
      frameTimes.push event.time

      text.content = (frameTimes.length /
        (frameTimes[frameTimes.length - 1] - frameTimes[0]))
      text.position = Paper.view.bounds.topLeft.add (new Paper.Point(20, 20))

      s = (event.time - time)
      ms = s * 1000
      time = event.time

      # pixels / s
      scrollAccel = 500

      if scrolling?
        scrollTime += s
        scrollSpeed = scrollAccel * scrollTime

        scrollMagnitude = scrollSpeed * s + 50

      else
        scrollTime = 0

      unless Paper.project.paused
        for c in w.objects
          c.update(ms)

    tool = new Paper.Tool()
    tool.onKeyDown = (event) =>
      if event.key == 'left'
        scrolling = 'left'
      if event.key == 'right'
        scrolling = 'right'
      if event.key == 'up'
        scrolling = 'up'
      if event.key == 'down'
        scrolling = 'down'

      if event.key == 'space'
        minigame = new Minigame()
        minigame.render()

      scrollVectors =
        up: new Paper.Point(0, -1)
        down: new Paper.Point(0, 1)
        left: new Paper.Point(-1, 0)
        right: new Paper.Point(1, 0)

      if scrolling of scrollVectors and scrollMagnitude?
        scrollVector = scrollVectors[scrolling].normalize(scrollMagnitude)
        scrollVector.x = Math.floor scrollVector.x
        scrollVector.y = Math.floor scrollVector.y

        Paper.view.scrollBy scrollVector
        scrollVector = null

    tool.onKeyUp = (event) =>
      scrolling = null

    tool.onMouseUp = (event) =>
      hitResult = Paper.project.hitTest(event.downPoint, hitOptions)
      if hitResult?
        debugger
      if w.numCells() >= 1 and not introducedVirus
        unless hitResult?
          v = new Virus(event.point, w)
          w.add v
          v.activate()
          introducedVirus = true
  
module.exports = App
