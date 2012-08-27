Paper = require 'lib/paper'
Key = require('views/key').key
Lock = require('views/key').lock

colorSequence = require('views/key').colorSequence

hitOptions =
  segments: false
  stroke: true
  fill: true
  tolerance: 1

class Info
  @header: "INFECT CELL"

  constructor: () ->


class Minigame
  constructor: (@virus, @cell) ->
    @timer = 10
    @callback = ->

  elements: []

  moveBox: (delta) ->
    for element in @elements
      element.position = element.position.add delta

  drawBox: () ->
    bounds = Paper.view.bounds

    rect = new Paper.Rectangle(0, 0, 500, 300)
    @box = new Paper.Path.RoundRectangle(rect, 6)
    @box.position = Paper.view.center
    @box.fillColor = 'white'
    @elements.push @box

  drawKey: () ->
    @key = new Key(@virus.key)
    @key.render()

    @elements.push @key.group
    @key.group.position = @box.position.add new Paper.Point(0, 0)

  drawLock: () ->
    @lock = new Lock()
    @lock.render()

    @elements.push @lock.group
    @lock.group.position = @box.position.add new Paper.Point(100, 0)

  drawTimer: () ->
    @timerText = new Paper.PointText(
      @box.bounds.topLeft.add new Paper.Point(20, 40)
    )
    @timerText.characterStyle.fontSize = 20
    @timerText.content = "0:10"
    @elements.push @timerText

  drawAmount: () ->
    @successText = new Paper.PointText(
      @box.bounds.topLeft.add new Paper.Point(20, 80)
    )
    @successText.characterStyle.fontSize = 20
    @elements.push @successText
    @updateAmount()

  countDown: () ->
    @timer -= 1
    if @timer == 0
      setTimeout((=> @remove()), 200)

    @timerText.content = "0:0" + @timer

  updateAmount: () ->
    @successText.content = @virus.keyStrengthAgainst(@cell)

  onRemove: (callback) ->
    @callback = callback

  render: () ->
    @parentLayer = Paper.project.activeLayer
    @parentTool = Paper.tool

    Paper.project.paused = true
    
    @layer = new Paper.Layer()
    @layer.activate()

    @drawBox()
    @drawKey()
    @drawLock()
    @drawTimer()
    @drawAmount()

    @tool = @makeTool()
    @tool.activate()

    setInterval((=> @countDown()), 1000)

  checkKey: () ->
    @updateAmount()

    if @virus.canInfect(@cell)
      @successText.content = "Success!"
      setTimeout((=> @remove()), 1000)

  makeTool: () ->
    tool = new Paper.Tool()

    tool.onMouseDrag = (event) =>
      hitResult = Paper.project.hitTest(event.point, hitOptions)
      if hitResult?
        path = hitResult.item
        if path?
          @moveBox(event.delta)

    tool.onMouseDown = (event) =>
      hitResult = Paper.project.hitTest(event.point, hitOptions)
      if hitResult?
        path = hitResult.item
        if path? and @key.hasPath(path)
          @key.click(path)
          @virus.key = @key.slots
          @checkKey()

    tool.onKeyDown = (event) =>
      if event.key == 'space'
        @remove()

    tool

  remove: () ->
    Paper.project.paused = false

    @tool.remove()
    Paper.project.activeLayer.remove()
    @parentLayer.activate()
    @parentTool.activate()

    do @callback

module.exports =
  minigame: Minigame
  colors: colorSequence
