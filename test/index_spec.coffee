test = require './setup'
expect    = require('chai').expect

App = require 'index'

describe "App", ->

  beforeEach ->

  afterEach ->

  it 'should create the app', ->
    a = new App()
    expect(a.f).to.equal 1
