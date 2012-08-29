Paper = require 'lib/paper'
_ = require('underscore')

metaball = require( 'lib/effects').metaball
Object = require 'models/object'
Virus = require 'models/virus'

colors = require('views/minigame').colors

C_r = 0.1
DIVIDE_LENGTH = 1
DEATH_PERCENTAGE = 0.01 # 1% change of dying every second

REPRODUCTIVE_HEALTH = 80
MUTATION_RATE = 0.1

class Bacterium extends Object
  @_radius: 20

  @_style:
    fillColor: '#F3F3F2'

  @_symbol: null

  @symbol: ->
    return Bacterium._symbol if Bacterium._symbol?
    
    ball = new Paper.Path.Circle(new Paper.Point(0, 0), Bacterium._radius)
    ball.style = Bacterium._style

    Bacterium._symbol = new Paper.Symbol(ball)

  constructor: (@pos, @world, opts) ->
    super(@pos, Bacterium._radius, @world, opts)

    @lock = ['orange', 'orange', 'orange', 'orange']
    @infected = false
    @health = 50

    for k, v of opts
      this[k] = v

  remove: () ->
    if @placedSymbol?
      @placedSymbol.remove()
      delete @placedSymbol

    if @mitosis?
      @mitosis.remove()
      delete @mitosis
    
    if @scull?
      @scull.remove()
      delete @scull

  render: () ->
    @placedSymbol = Bacterium.symbol().place(@pos)

  divide: ->
    @health /= 2

    divideDirection = Math.random() * 360
    childPos = @pos.add new Paper.Point
      angle: divideDirection
      length: DIVIDE_LENGTH

    childLock = (color for color in @lock)
    if Math.random() < MUTATION_RATE
      keep = Math.floor(Math.random() * (@lock.length + 1))

      randomColor = (except) ->
        choices = _.without colors, except
        colorIdx = Math.floor(Math.random() * choices.length)
        choices[colorIdx]
      
      for i in [0 .. colors.length - 1]
        remaining = colors.length - i

        change = Math.random() < (keep / remaining)

        if change
          childLock[i] = randomColor(childLock[i])
          keep -= 1

    @child = new Bacterium childPos, @world,
      lock: childLock

    @ignoredCollisions.push @child
    @child.ignoredCollisions.push this

    @world.add @child

  die: ->
    if @isInfected()
      @spawn()

    super

  spawn: ->
    points = [
      @pos.add(new Paper.Point(-8, -7)),
      @pos.add(new Paper.Point(+8, -7)),
      @pos.add(new Paper.Point(-10, +9)),
      @pos.add(new Paper.Point(0, +14)),
      @pos.add(new Paper.Point(+10, +9))
    ]

    for point in points
      virus = new Virus point, @world,
        key: @crackingKey
      virus.moveAwayFrom @pos

      @world.add virus

  isBacterium: ->
    true

  isInfected: ->
    @infected

  infect: (virus) ->
    @infected = true
    @crackingKey = virus.key

    unless @scull?
      @scull = new Paper.Raster('scull')

  canDivide: ->
    @health > REPRODUCTIVE_HEALTH and not @infected

  canDie: ->
    @ignoredCollisions.length == 0

  updateHealth: (ms) ->
    s = ms / 1000
    if @isInfected()
      @health -= 25 * s
    else
      @health += Math.random() * 10  * s

    @health = 100 if @health > 100

    if @health <= 0 and @canDie()
      @die()

  update: (ms) ->
    if ms == 0
      return

    oldVel = @vel

    super

    if @child?
      @child.moveAwayFrom(this.pos)
      @moveAwayFrom(@child.pos)

      @mitosis = metaball(this, @child, @r * 2)
      if @scull? and @mitosis?
        @mitosis.moveBelow @scull

      if @mitosis == null
        @ignoredCollisions = _.without(@ignoredCollisions, @child)
        @child.ignoredCollisions = _.without(@child.ignoredCollisions, this)
        @child = null
    else
      # divide
      if @canDivide()
        overcrowdingBias = (150 / Math.sqrt(@world.numBacteria()) - 17) / 100
        attempt = Math.random()

        @divide() if attempt < (overcrowdingBias * ms / 1000)

    @updateHealth(ms)

  move: (ms) ->
    super

    @updatePosition()

  updatePosition: ->
    if @placedSymbol?
      @placedSymbol.position = @pos

    if @mitosis?
      @mitosis.remove()
      delete @mitosis

    if @isInfected()
      @scull.position = @pos

  moveAwayFrom: (pos, ms) ->
    dir = @pos.subtract(pos)
    delta = dir.normalize(@speed)
    
    @vel = @vel.add delta

  moveToward: (pos) ->
    dir = pos.subtract(@pos)
    delta = dir.normalize(@speed)
    @vel = @vel.add delta

module.exports = Bacterium
