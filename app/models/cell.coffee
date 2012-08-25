Paper = require 'lib/paper'

getVector = (radians, length) ->
  new Paper.Point
    angle: radians * 180 / Math.PI
    length: length

class Cell
  constructor: (@pos, @r, @p) ->

  render: ->
    @ball = new Paper.Path.Circle(@pos, @r)

  remove: =>
    @ball.remove()

  metacell: (other, v = 0.5, maxDistance = 200, handleLenRate = 2.4) ->
    d = @pos.getDistance other.pos

    if d > maxDistance
      return

    if d < @r + other.r
      u1 = Math.acos((@r * @r + d * d - other.r * other.r) / (2 * @r * d))
      u2 = Math.acos((other.r * other.r + d * d - @r * @r) / (2 * other.r * d))
    else
      u1 = 0
      u2 = 0

    angle1 = (other.pos.subtract @pos).getAngleInRadians()
    angle2 = Math.acos((@r - other.r) / d)
    angle1a = angle1 + u1 + (angle2 - u1) * v
    angle1b = angle1 - u1 - (angle2 - u1) * v
    angle2a = angle1 + Math.PI - u2 - (Math.PI - u2 - angle2) * v
    angle2b = angle1 - Math.PI + u2 + (Math.PI - u2 - angle2) * v

    p1a = @pos.add getVector(angle1a, @r)
    p1b = @pos.add getVector(angle1b, @r)
    p2a = other.pos.add getVector(angle2a, other.r)
    p2b = other.pos.add getVector(angle2b, other.r)

    totalRadius = @r + other.r
    d2 = Math.min(v * handleLenRate, (p1a.subtract p2a).length / totalRadius)

    d2 *= Math.min(1, d * 2 / (@r + other.r))

    radius1 = @r * d2
    radius2 = other.r * d2

    path = new Paper.Path([p1a, p2a, p2b, p1b])
    path.style = @ball.style
    path.closed = true

    segments = path.segments
    segments[0].handleOut = getVector(angle1a - Math.PI / 2, radius1)
    segments[1].handleIn = getVector(angle2a + Math.PI / 2, radius2)
    segments[2].handleOut = getVector(angle2b - Math.PI / 2, radius2)
    segments[3].handleIn = getVector(angle1b + Math.PI / 2, radius1)

    path


module.exports = Cell
