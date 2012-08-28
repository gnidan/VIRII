$ = require 'jqueryify2'

Paper = require 'lib/paper'

Game = require 'models/game'

class App
  constructor: ->
    canvas = $('#game')[0]
    Paper.setup(canvas)
    @game = new Game(canvas)

  render: ->
    @game.start()
  
module.exports = App
