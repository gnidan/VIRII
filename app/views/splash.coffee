Paper = require 'lib/paper'

hitOptions =
  segments: true
  stroke: true
  fill: true
  tolerance: 5

class Splash
  constructor: ->
  
  elements: []

  drawBox: ->
    bounds = Paper.view.bounds

    rect = new Paper.Rectangle(0, 0, 400, 350)
    @box = new Paper.Path.RoundRectangle(rect, 6)
    @box.position = Paper.view.center.add new Paper.Point(0, 200)
    @box.fillColor = 'white'
    @elements.push @box

  drawText: ->
    @header = new Paper.PointText(
      @box.bounds.topCenter.add new Paper.Point(0, 40)
    )

    @header.characterStyle.fontSize = 20
    @header.characterStyle.font = "Helvetica"
    @header.paragraphStyle.justification = "center"
    @header.content = "VIRII"
    
    lines = [
      "     In VIRII, you control a strain of virus.",
      "Your goal is to take over an evolving ",
      "colony of bacteria.",
      "",
      "     Click to introduce your first virus. When",
      "you collide with your first bacteria, attempt",
      "to hack into it!",
      "",
      "     Click on viruses to take control so you",
      "can hack into more resilient bacteria. You",
      "can also use the arrow keys to look",
      "around. Hit space to pause."
    ]

    pos = @box.bounds.topLeft.add new Paper.Point(20, 70)
    for line in lines
      text = new Paper.PointText(pos)
      text.characterStyle.fontSize = 14
      text.characterStyle.font = "Helvetica"
      text.content = line

      pos = pos.add new Paper.Point(0, 20)

  drawLoading: ->
    @loading = new Paper.PointText(
      @box.bounds.bottomCenter.add new Paper.Point(0, -20))
    @loading.characterStyle.fontSize = 12
    @loading.characterStyle.font = "Helvetica"
    @loading.paragraphStyle.justification = "center"
    @loading.content = "Populating..."

  drawPlay: ->
    pos = @box.bounds.bottomCenter.add new Paper.Point(0, -20)

    playRect = new Paper.Rectangle(pos.x - 40, pos.y - 21, 80, 30)
    @playBox = new Paper.Path.RoundRectangle(playRect, 6)
    @playBox.style.fillColor = "#5B6169"

    @play = new Paper.PointText(pos)

    @play.characterStyle.fillColor = "#00FFFF"
    @play.characterStyle.fontSize = 12
    @play.characterStyle.font = "Helvetica"
    @play.paragraphStyle.justification = "center"
    @play.content = "PLAY"

  render: ->
    @parentTool = Paper.tool
    @parentLayer = Paper.project.activeLayer
    @parentLayer.opacity = 0.2

    @tool = new Paper.Tool()
    @tool.onMouseUp = (event) =>
      hitResult = Paper.project.hitTest(event.point, hitOptions)
      if hitResult? and @play?
        @remove()

    @tool.activate()

    @layer = new Paper.Layer()
    @layer.activate()

    @drawBox()
    @drawText()
    @drawLoading()

    @parentLayer.activate()

  done: ->
    Paper.project.paused = true
    @layer.activate()
    @loading.remove()
    @drawPlay()

  remove: ->
    Paper.project.paused = false
    @parentLayer.opacity = 1
    @parentLayer.activate()
    @parentTool.activate()
    @layer.remove()
    @tool.remove()

module.exports = Splash
