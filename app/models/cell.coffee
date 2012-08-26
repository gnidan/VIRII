Paper = require 'lib/paper'
_ = require('underscore')

metacell = require( 'lib/effects').metacell
Object =require('models/object')

C_r = 0.1
DIVIDE_LENGTH = 1
CRITICAL_MASS = 4000

class Cell extends Object
  defaults:
    fillColor: 'black'

  constructor: (@pos, @world, opts) ->
    r = 20
    super(@pos, r, @world, opts)

  divide: ->
    @mass = @mass / 2

    divideDirection = Math.random() * 360
    childPos = @pos.add new Paper.Point
      angle: divideDirection
      length: DIVIDE_LENGTH

    @child = new Cell(childPos, @world)
    @child.render()

    @ignoredCollisions.push @child
    @child.ignoredCollisions.push this

    @world.push @child

  update: (ms) ->
    if ms == 0
      return

    oldVel = @vel

    super

    # just add some mass for testing
    @mass += ms / 2

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
