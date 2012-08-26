Paper = require 'lib/paper'

class Minigame
  constructor: (@virus, @cell) ->

  render: () ->
    Paper.project.paused = true

    bounds = Paper.view.bounds
    
    @parentLayer = Paper.project.activeLayer
    Paper.project.paused = true
    @layer = new Paper.Layer()
    @layer.opacity = 0.2
    @layer.activate()

    rect = new Paper.Rectangle(bounds.x + 100, bounds.y + 100,
      bounds.width - 200, bounds.height - 200)
    box = new Paper.Path.RoundRectangle(rect, 6)
    box.fillColor = 'black'

  remove: () ->
    Paper.project.paused = false

    Paper.project.activeLayer.remove()
    @parentLayer.activate()

module.exports = Minigame
