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
    c2 = new Cell(new Paper.Point(250, 130), 60)
    c.render()
    c2.render()

    path = c.metacell c2

    Paper.view.draw()
    
    remove = ->
      path.remove()
      Paper.view.draw()

    setTimeout(remove, 2000)

  
module.exports = App
