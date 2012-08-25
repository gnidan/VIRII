require 'lib/crafty'

Crafty = window.Crafty

class App
  constructor: ->
    console.log "fnord"

  render: ->
    Crafty.init(400, 400)

    Crafty.scene "loading", ->
      Crafty.background("#000")
      Crafty.e("2D, DOM, Text")
        .attr({ w: 100, h: 100, x: 150, y: 120})
        .text("Loading")
        .css({ 'text-align': 'center' })

    Crafty.scene('loading')
  
module.exports = App
