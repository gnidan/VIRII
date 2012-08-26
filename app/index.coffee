$ = require 'jqueryify2'

Paper = require 'lib/paper'
Cell = require 'models/cell'
Virus = require 'models/virus'

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

    w = []
    c1 = new Cell(new Paper.Point(500, 400), w)
    v = new Virus(new Paper.Point(300, 300), w)

    w.push c1
    w.push v

    divide = ->
      c1.divide()

    paused = false
    time = 0
    frameTimes = []
    text = new Paper.PointText(new Paper.Point(20, 20))
    text.characterStyle.fontSize = 20
    Paper.view.onFrame = (event) ->
      if frameTimes.length > 60
        frameTimes = frameTimes.slice(1)
      frameTimes.push event.time

      text.content = (frameTimes.length /
        (frameTimes[frameTimes.length - 1] - frameTimes[0]))

      ms = (event.time - time) * 1000
      unless paused
        for c in w
          c.update(ms)

      time = event.time

    tool = new Paper.Tool()
    tool.onMouseDown = (event) ->
      hitResult = Paper.project.hitTest(event.point, hitOptions)
      if hitResult?
        path = hitResult.item
        cell = null
        for c in w
          cell = c if c.ball.id == path.id
          
        cell.fillColor = 'red'
        window.clickedCell = cell
        paused = true
      else
        paused = false


  
module.exports = App
