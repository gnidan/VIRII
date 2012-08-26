Paper = require 'lib/paper'
_ = require('underscore')

metacell = require( 'lib/effects').metacell

C_r = 0.1
DIVIDE_LENGTH = 1
CRITICAL_MASS = 4000

class Cell
  defaults:
    fillColor: 'black'

  constructor: (@pos, @r, @world, opts) ->
    # pixels / s
    @speed = 60
    @vel = new Paper.Point(0, 0)

    # velocity magnituded reduced per second
    @damping = 0.999

    @newVel = null
    @task = null
    @mass = Math.PI * @r * @r

    @ignoredCollisions = []

    for k, v of @defaults
      this[k] = v
    for k, v of opts
      this[k] = v

  render: ->
    @ball = new Paper.Path.Circle(@pos, @r)
    @ball.fillColor = @fillColor

  remove: =>
    @ball.remove()

  collidesWith: (object) ->
    d = @pos.getDistance object.pos
    newD = object.pos.add(object.vel.divide(2))
      .getDistance(@pos.add(@vel.divide(5)))

    (newD < @r + object.r)

  checkCollisions: ->
    collisions = []
    for object in @world
      if object.ball.id == @ball.id
        continue

      if @collidesWith object
        dontCollide = @ignoredCollisions
        collisions.push object unless object in dontCollide

    collisions

  divide: ->
    @mass = @mass / 2

    divideDirection = Math.random() * 360
    childPos = @pos.add new Paper.Point
      angle: divideDirection
      length: DIVIDE_LENGTH

    @child = new Cell(childPos, @r, @world)
    @child.render()

    @ignoredCollisions.push @child
    @child.ignoredCollisions.push this

    @world.push @child

  update: (ms) ->
    if @ball?
      @ball.remove()
      delete @ball
    if @mitosis?
      @mitosis.remove()
      delete @mitosis

    @render()

    if ms == 0
      return

    # just add some mass for testing
    @mass += ms / 2

    @move(ms)
    collisions = @checkCollisions()

    if @child?
      @child.moveAwayFrom(this.pos)
      @moveAwayFrom(@child.pos)

      @mitosis = metacell(this, @child, @r * 2)

      if @mitosis == null
        @ignoredCollisions = _.without(@ignoredCollisions, @child)
        @child.ignoredCollisions = _.without(@child.ignoredCollisions, this)
        @child = null
    else
      # divide
      if @mass > CRITICAL_MASS and @world.length < 32
        @divide()

    vels = []
    for other in collisions
      other.pos.add(@pos.subtract(other.pos).normalize(1))

      vels.push other.vel.subtract(@vel).multiply(C_r * other.mass)
        .add(@vel.multiply(@mass))
        .add(other.vel.multiply(other.mass))
        .divide(@mass + other.mass)

    newVel = _.reduce(vels, ((sum, vel) -> sum.add(vel)), new Paper.Point(0, 0))

    @vel = @vel.add newVel

    for child in @ignoredCollisions
      child.vel = child.vel.add newVel

  move: (ms) ->
    @vel = @vel.normalize(@speed) if @vel.length > @speed

    oldPos = @ball.position

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

module.exports = Cell
