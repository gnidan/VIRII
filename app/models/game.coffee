Paper = require 'lib/paper'

Colors = require 'lib/colors'

World = require 'models/world'
Cell = require 'models/cell'
Virus = require 'models/virus'

Splash = require 'views/splash'

class Game
  @_showFPS = true

  constructor: (@canvas) ->
    @world = new World @canvas, this

    @cellLayer = new Paper.Layer()

    @tool = @_makeGameTool()
    
  start: ->
    @cellLayer.activate()
    @lives = 3
    @time = 0

    @_setup()

    game = this
    Paper.view.onFrame = (event) ->
      game.update(event.time)

  ##
  # Setup
  ##
  _settingUp: false

  _setup: ->
    @unpause()

    @_generateCell(new Paper.Point(500, 300))

    @_settingUp = true
    @_showInfo()

    if Game._showFPS
      @_fpsText = new Paper.PointText(new Paper.Point(20, 20))
      @_fpsText.characterStyle.fontSize = 20

  _finishSetup: ->
    @_settingUp = false
    @pause()
    @_splash.done()
    @_splash.onRemove =>
      @unpause()


  ##
  # Game tick
  ##
  update: (newTime) ->
    @_calculateFramerate(newTime)

    s = newTime - @time
    ms = s * 1000
    @time = newTime

    @_updateScrollTime(s)

    if @_settingUp
      ms = ms * 10
      if @world.numCells() > 30
        @_finishSetup()

    unless @paused()
      for object in @world.objects
        object.update(ms)

  ##
  # PAUSE
  ##
  paused: ->
    @_paused

  pause: ->
    @_paused = true

  unpause: ->
    @_paused = false

  ##
  # Mouse interaction
  ##
  _clickedObject: (object) ->
    if object.isVirus()
      object.activate()

  _clickedNothing: (pos) ->
    if @world.numViruses() == 0 and @world.numInfectedCells() == 0 and \
          @lives >= 0
      @_generateVirus(pos)
      @lives -= 1

  ##
  # SCROLLING
  ##
  @_scrollAccel: 500 # pixels / s
  _scrollTime: 0
  _scrolling = false
  _scrollAmount = 0

  _scroll: ->
    @_scrolling = true

  _stopScrolling: ->
    @_scrolling = false
    @scrollTime = 0

  _updateScrollTime: (s) ->
    if @_scrolling
      @_scrollTime += s
      @_updateScrollAmount(s)

  _updateScrollAmount: (s) ->
    scrollSpeed = Game._scrollAccel * @_scrollTime
    @_scrollAmount = scrollSpeed * s + 50

  ##
  # Dialog generators
  ##
  _showInfo: ->
    @_splash = new Splash()
    @_splash.render()

  ##
  # Object generators
  ##
  _generateCell: (pos) ->
    cell = new Cell pos, @world,
      lock: Colors.randomSequence()

    @world.add cell
    cell

  _generateVirus: (pos) ->
    color = Colors.randomColor()
    virus = new Virus pos, @world,
      key: [color, color, color, color]

    @world.add virus
    virus.activate()
    virus

  ##
  # Framerate
  ##

  @_framesToKeep = 60
  _framesBuffer: []
  
  _calculateFramerate: (now) ->
    if @_framesBuffer.length > Game.framesToKeep
      @_framesBuffer = @_framesBuffer.slice(1)
    @_framesBuffer.push now

    firstInBuffer = @_framesBuffer[0]
    lastInBuffer = @_framesBuffer[@_framesBuffer.length - 1]
    
    fps = @_framesBuffer.length / (lastInBuffer - firstInBuffer)

    if Game._showFPS
      newLocation = Paper.view.bounds.topLeft.add new Paper.Point(20,20)
      @_fpsText.content = fps
      @_fpsText.position = newLocation

  ##
  # Game interaction tool
  ##
  _makeGameTool: ->
    tool = new Paper.Tool()
    game = this # to put in closure for events to have access to game

    tool.onKeyDown = (event) ->
      if event.key == 'space'
        if game.paused()
          game.unpause()
        else
          game.pause()
      else
        scrollVectors =
          up: new Paper.Point(0, -1)
          down: new Paper.Point(0, 1)
          left: new Paper.Point(-1, 0)
          right: new Paper.Point(1, 0)

        if event.key of scrollVectors
          game._scroll()
          scrollAmount = game._scrollAmount

          scrollVector = scrollVectors[event.key].normalize(scrollAmount)
          scrollVector.x = Math.floor scrollVector.x
          scrollVector.y = Math.floor scrollVector.y

          Paper.view.scrollBy scrollVector

    tool.onKeyUp = (event) ->
      game._stopScrolling()

    tool.onMouseUp = (event) ->
      hitResult = game.world.objectAtPoint(event.point)

      if hitResult?
        game._clickedObject(hitResult)
      else
        game._clickedNothing(event.point)

module.exports = Game
