jsdom = require('jsdom').jsdom
global.document or= jsdom()
global.window   or= global.document.createWindow()
global.navigator =
  userAgent: 'WebKit'

module.exports =
  create: ->
    @_setup()

  destroy: ->
    document.write ''

  fail: ->
    throw new Error(arguments...)

  _setup: ->
