$ = require 'jqueryify2'

Paper = require 'lib/paper'
Cell = require 'models/cell'

class App
  constructor: ->
    console.log "fnord"

  render: ->
    canvas = $('#game')[0]

    Paper.setup(canvas)
    Paper.project.currentStyle =
      fillColor: 'black'

    c = new Cell(new Paper.Point(100, 100), 40)
    c2 = new Cell(new Paper.Point(105, 120), 60)


    c.render()
    c2.render()
    path = c.metacell c2
    Paper.view.onFrame = ->
      c.remove()
      c2.remove()
      path.remove() if path?

      c.render()
      c2.render()

      c2.moveAwayFrom(c, 1)

      path = c.metacell c2


  
module.exports = App
