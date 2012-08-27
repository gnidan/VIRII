Paper = require 'lib/paper'
_ = require 'underscore'

Object = require 'models/object'
Minigame = require('views/minigame').minigame

class Virus extends Object
  @_radius: 5

  @_style:
    fillColor: '#00FFFF'

  @_activeStyle:
    fillColor: '#FF0000'

  @_symbol: null
  @_activeSymbol: null

  @symbol: ->
    return Virus._symbol if Virus._symbol?
    
    ball = new Paper.Path.Circle(new Paper.Point(0, 0), Virus._radius)
    ball.style = Virus._style

    Virus._symbol = new Paper.Symbol(ball)

  @activeSymbol: ->
    return Virus._activeSymbol if Virus._activeSymbol?
    
    ball = new Paper.Path.Circle(new Paper.Point(0, 0), Virus._radius)
    ball.style = Virus._activeStyle

    Virus._activeSymbol = new Paper.Symbol(ball)

  constructor: (@pos, @world, opts) ->
    super(@pos, Virus._radius, @world, opts)

    @speed = 60
    @damping = 0.4

    @health = 100

    @key = ['orange', 'orange', 'orange', 'orange']

    for k, v of opts
      this[k] = v

  isVirus: ->
    true

  activate: ->
    @world.activate(this)
    @active = true
    if @item?
      @item.style = Virus._activeStyle

  deactivate: ->
    @active = false

    if @item?
      @item.style = Virus._style

  keyStrengthAgainst: (cell) ->
    compare = (color for color in @key)

    max = 0
    for i in [0 .. cell.lock.length - 1]
      compare = compare.slice(1, compare.length).concat compare.slice(0, 1)
      console.log compare

      subsequence = 0
      for j in [0 .. compare.length - 1]
        if compare[j] == cell.lock[j]
          subsequence += 1
        else
          subsequence = 0
        max = subsequence if subsequence > max
    max

  canInfect: (cell) ->
    @keyStrengthAgainst(cell) == @key.length

  resolveCollision: (other) ->
    super
    
    if other.isCell()
      if @active
        minigame = new Minigame(this, other)
        minigame.render()

        minigame.onRemove =>
          if @canInfect other
            other.infect(this)
          @die()

      else
        if @canInfect other
          other.infect(this)

        @die()

  render: () ->
    @item = new Paper.Path.Circle(@pos, Virus._radius)
    @item.style = Virus._style

  remove: () ->
    if @item?
      @item.remove()
      delete @item

  move: (ms) ->
    super

    @updatePosition()

  updatePosition: ->
    if @item?
      @item.position = @pos

  jitter: (ms) ->
    CHANGE_DIR_CHANCE = 0.9
    s = ms / 1000
    changeDir = Math.random() < (CHANGE_DIR_CHANCE * s)
    
    changeDir = @vel.length < 1

    if changeDir and @world.objects.length > 0
      idx = Math.floor(Math.random() * @world.objects.length)
      randomObject = @world.objects[idx]
      @moveToward(randomObject.pos)

  update: (ms) ->
    super

    @jitter(ms)

    @updateHealth(ms)

  updateHealth: (ms) ->
    decay = 12
    s = ms / 1000
    @health -= decay * s

    if @health <= 0
      @die()

module.exports = Virus
