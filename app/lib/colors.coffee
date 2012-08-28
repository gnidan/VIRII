_ = require 'underscore'

class Colors
  @colors: ['orange', 'yellow', 'purple', 'cyan']

  @hexValues:
    orange: '#C88956'
    yellow: '#C8C856'
    purple: '#6B3E86'
    cyan: '#347A77'

  @randomColor: (exceptions...) ->
    colors = _.without(Colors.colors, exceptions...)
    colorIdx = Math.floor(Math.random() * colors.length)
    colors[colorIdx]

  @randomSequence: (length = 4) ->
    seq = []
    for i in [0 .. length - 1]
      seq.push Colors.randomColor()


module.exports = Colors
