$ = require 'jqueryify2'

Paper = require 'lib/paper'
Cell = require 'models/cell'

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
    c1 = new Cell(new Paper.Point(300, 300), 20, w)

    point = new Paper.Point(600, 600)

    w.push c1

    divide = ->
      c1.divide()

    paused = false
    time = 0
    Paper.view.onFrame = (event) ->
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
