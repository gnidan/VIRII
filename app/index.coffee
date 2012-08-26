$ = require 'jqueryify2'

Paper = require 'lib/paper'
Cell = require 'models/cell'
Virus = require 'models/virus'
World = require 'models/world'
Minigame = require 'views/minigame'

Effects = require 'lib/effects'

hitOptions =
  segments: false
  stroke: true
  fill: true
  tolerance: 5

class App
  constructor: ->
    console.log "fnord"

  render: ->
    canvas = $('#game')[0]

    Paper.setup(canvas)

    cellLayer = new Paper.Layer()
    cellLayer.opacity = 0.8
    cellLayer.activate()

    w = new World(canvas)
    c1 = new Cell(new Paper.Point(500, 400), w)

    w.add c1

    frameTimes = []
    text = new Paper.PointText(new Paper.Point(20, 20))
    text.characterStyle.fontSize = 20

    time = 0

    minigame = new Minigame()
      
#    setTimeout(minigame.render, 5000)
#    setTimeout(minigame.remove, 7000)

    Paper.view.onFrame = (event) ->
      if frameTimes.length > 60
        frameTimes = frameTimes.slice(1)
      frameTimes.push event.time

      text.content = (frameTimes.length /
        (frameTimes[frameTimes.length - 1] - frameTimes[0]))

      ms = (event.time - time) * 1000
      time = event.time

      unless Paper.project.paused
        for c in w.objects
          c.update(ms)

    tool = new Paper.Tool()
    tool.onMouseDown = (event) ->
      hitResult = Paper.project.hitTest(event.point, hitOptions)
      if hitResult?
        path = hitResult.item
        cell = null
        for c in w.objects
          cell = c if c.ball.id == path.id
          
        cell.fillColor = 'red'


  
module.exports = App
