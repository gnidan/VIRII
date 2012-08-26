$ = require 'jqueryify2'

Paper = require 'lib/paper'
Cell = require 'models/cell'
Virus = require 'models/virus'
World = require 'models/world'

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
    Paper.project.currentStyle =
      fillColor: 'black'

    w = new World(canvas)
    c1 = new Cell(new Paper.Point(500, 400), w)
    v = new Virus(new Paper.Point(450, 350), w)

    w.add c1
    w.add v

    divide = ->
      c1.divide()

    frameTimes = []
    text = new Paper.PointText(new Paper.Point(20, 20))
    text.characterStyle.fontSize = 20

    time = 0

    pause: ->
      Paper.project.paused = true

    minigame = ->
      parentLayer = Paper.project.activeLayer
      Paper.project.paused = true
      layer = new Paper.Layer()
      layer.activate()
      Paper.project.currentStyle =
        fillColor: 'red'

      new Paper.Path.Rectangle(100, 100, 400, 400)
      
      setTimeout((-> Paper.project.activeLayer.remove(); parentLayer.activate(); Paper.project.paused = false), 3000)

    #setTimeout(minigame, 1000)

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
