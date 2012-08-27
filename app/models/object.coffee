Paper = require 'lib/paper'
_ = require('underscore')

C_r = 0.1

class Object
  @_lastId: 0
  @_getNewId: ->
    Object._lastId += 1
    Object._lastId
    
  constructor: (@pos, @r, @world) ->
    @id = Object._getNewId()

    # pixels / s
    @speed = 20
    @vel = new Paper.Point(0, 0)

    # velocity magnituded reduced per second
    @damping = 0.999

    @mass = Math.PI * @r * @r

    @ignoredCollisions = []

    @render()

  isObject: ->
    true

  isCell: ->
    false

  isVirus: ->
    false

  render: ->

  remove: ->

  collidesWith: (object) ->
    d = @pos.getDistance object.pos

    (d * d <= (@r + object.r) * (@r + object.r))

  checkCollisions: ->
    collisions = []
    for object in @world.objects
      if object.id == @id
        continue
      
      if @collidesWith object
        collisions.push object unless object in @ignoredCollisions

    collisions

  die: ->
    @remove()
    @world.remove this
    delete this

  update: (ms) ->
    if ms == 0
      return

    @move(ms)

    collisions = @checkCollisions(ms)

    for other in collisions
      if other.isVirus()
        other.resolveCollision this
      else
        this.resolveCollision other

  resolveCollision: (other) ->
    delta = @pos.subtract other.pos
    d = delta.length
    mtd = delta.multiply(((@r + other.r) - d) / d)

    im1 = 1 / @mass
    im2 = 1 / other.mass

    @pos = @pos.add(mtd.multiply(im1 / (im1 + im2)))
    other.pos = other.pos.subtract(mtd.multiply(im2 / (im1 + im2)))

    v = (@vel.subtract(other.vel))
    vn = v.dot(mtd.normalize())

    if vn > 0
      return

    i = (-(1 + C_r) * vn) / (im1 + im2)
    impulse = mtd.multiply(i)

    @vel = @vel.add impulse.multiply(im1)
    other.vel = other.vel.subtract(impulse.multiply(im2))

  move: (ms) ->
    @vel = @vel.normalize(@speed) if @vel.length > @speed

    oldPos = @pos

    s = ms / 1000

    delta = @vel.multiply s

    newPos = oldPos.add delta

    @pos = newPos

    @vel = @vel.multiply(1 - @damping * s)

  moveAwayFrom: (pos, ms) ->
    dir = @pos.subtract(pos)
    delta = dir.normalize(@speed)
    @vel = @vel.add delta

  moveToward: (pos) ->
    dir = pos.subtract(@pos)
    delta = dir.normalize(@speed)
    @vel = @vel.add delta

module.exports = Object
