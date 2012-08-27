Paper = require 'lib/paper'

colors =
  orange: '#C88956'
  yellow: '#C8C856'
  purple: '#6B3E86'
  cyan: '#347A77'

colorSequence = ['orange', 'yellow', 'purple', 'cyan']

class Sequence
  @slotBox: new Paper.Rectangle(0, 0, 24, 24)

  constructor: (@slots = ['?','?','?','?']) ->
    @group = new Paper.Group()
    @boxes = []

  render: (coords = new Paper.Point(0, 0)) ->
    for slot in @slots
      rect = Key.slotBox.clone()

      box = new Paper.Path.RoundRectangle(rect, 1)
      box.strokeColor = '#353D46'
      box.strokeWidth = 1
      box.smooth()
      box.position = coords

      if slot in colorSequence
        box.fillColor = colors[slot]
      else
        box.fillColor = '#919191'
        questionMark = new Paper.PointText(coords.add(new Paper.Point(-5, 7)))
        questionMark.characterStyle.fontSize = 14
        questionMark.characterStyle.font = 'Helvetica'
        questionMark.fillColor = 'black'
        questionMark.content = '?'
        @group.appendTop questionMark

      coords = coords.add new Paper.Point(0, 25)

      @boxes.push box
      @group.appendBottom box

    coords


class Key extends Sequence

  constructor: (slots = ['orange', 'purple', 'cyan', 'yellow']) ->
    super(slots)

  click: (path) ->
    idx = @boxes.indexOf path

    newColor = colorSequence[(colorSequence.indexOf(@slots[idx]) + 1) % 4]

    @slots[idx] = newColor
    path.fillColor = colors[newColor]

  hasPath: (path) ->
    path in @boxes

class Lock extends Sequence
  constructor: () ->
    slots = []
    for i in [0..6]
      slots.push '?'

    super(slots)

  render: (coords = new Paper.Point(0, 0)) ->
    dotsTop = new Paper.PointText(coords.add(new Paper.Point(0, -10)))
    dotsTop.characterStyle.fontSize = 20
    dotsTop.characterStyle.font = 'Times New Roman'
    dotsTop.fillColor = 'black'
    dotsTop.content = "..."
    dotsTop.rotate 90

    coords = coords.add new Paper.Point(0, 25)
    @group.appendTop dotsTop

    coords = super(coords)
    coords.add new Paper.Point(0, 25)

    dotsBottom = new Paper.PointText(coords.add(new Paper.Point(0, -10)))
    dotsBottom.characterStyle.fontSize = 20
    dotsBottom.characterStyle.font = 'Times New Roman'
    dotsBottom.fillColor = 'black'
    dotsBottom.content = "..."
    dotsBottom.rotate 90

    @group.appendTop dotsBottom
    


module.exports =
  key: Key
  lock: Lock
  colorSequence: colorSequence
