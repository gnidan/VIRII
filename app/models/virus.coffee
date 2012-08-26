Paper = require 'lib/paper'
_ = require 'underscore'

Object = require 'models/object'

class Virus extends Object
  defaults:
    fillColor:
      'cyan'

  constructor: (@pos, @world, opts) ->
    r = 5
    super(@pos, r, @world, opts)

  resolveCollision: (other) ->
    super

    if other.isCell()
      @removed = true
      @ball.remove()
      @world.remove this
      other.infect(this)

  render: () ->
    super


module.exports = Virus
