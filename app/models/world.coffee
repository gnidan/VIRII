_ = require 'underscore'

class World
  constructor: (@canvas) ->
    @objects = []
    @length = 0

  add: (object) ->
    @objects.push object
    @length += 1

  remove: (object) ->
    @objects = _.without @objects, object
    @length = @objects.length

  isObject: ->
    false

  isWorld: ->
    true

  objectHitsBoundary: (object) ->
    object.pos.x - object.r < 0 or
    object.pos.x + object.r > @canvas.width or
    object.pos.y - object.r < 0 or
    object.pos.y + object.r < @canvas.height

module.exports = World
