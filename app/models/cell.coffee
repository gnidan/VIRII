Paper = require 'lib/paper'
_ = require('underscore')

metacell = require( 'lib/effects').metacell
Object = require 'models/object'
Virus = require 'models/virus'

C_r = 0.1
DIVIDE_LENGTH = 1
CRITICAL_MASS = 4000


class Cell extends Object
  @_symbol: null
  @_getNewId: ->
    

  defaults:
    fillColor: 'black'

  constructor: (@pos, @world, opts) ->
    r = 20
    super(@pos, r, @world, opts)

    @infected = false
    @viruses = []

  objectHitsBoundary: (object) ->

  remove: () ->
    super

    if @mitosis?
      @mitosis.remove()
      delete @mitosis

    for virus in @viruses
      virus.ball.remove()

  render: () ->
    super

    for virus in @viruses
      virus.render()

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

    @world.add @child

  isCell: ->
    true

  isWorld: ->
    true

  infect: (virus) ->
    @infected = true

  canDivide: ->
    (@mass > CRITICAL_MASS) and (@world.length < 32) and not @infected

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
      if @canDivide()
        @divide()

    if @infected and @mass > CRITICAL_MASS
      @spawn()

  spawn: ->
    virus = new Virus(@pos, this)
    @ignoredCollisions.push virus
    virus.ignoredCollisions.push this

    @viruses.push virus
    console.log @viruses.length

  moveAwayFrom: (pos, ms) ->
    dir = @pos.subtract(pos)
    delta = dir.normalize(@speed)
    
    @vel = @vel.add delta

  moveToward: (pos) ->
    dir = pos.subtract(@pos)
    delta = dir.normalize(@speed)
    @vel = @vel.add delta

module.exports = Cell
