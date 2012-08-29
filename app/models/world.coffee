_ = require 'underscore'

class World
  constructor: (@canvas, @parent) ->
    @objects = []
    @length = 0
    @viruses = []
    @bacteria = []
    @activeVirus = null
    @items = []

  numBacteria: () ->
    @bacteria.length

  numInfectedBacteria: () ->
    infectedBacteria = _.filter @bacteria, (bacterium) ->
      bacterium.isInfected()
    infectedBacteria.length

  numViruses: () ->
    @viruses.length

  printInfo: () ->
    console.log "Bacteria: " + @numBacteria()
    console.log "Viruses: " + @numViruses()
    console.log "Infected Bacteria: " + @numInfectedBacteria()

  add: (object) ->
    @objects.push object
    @length += 1

    if object.isBacterium()
      @bacteria.push object

    if object.isVirus()
      @viruses.push object

    @items[object.placedSymbol] = object

  remove: (object) ->
    @objects = _.without @objects, object
    @length = @objects.length

    if object.isBacterium()
      @bacteria = _.without @bacteria, object

    if object.isVirus()
      @viruses = _.without @viruses, object

    delete @items[object.placedSymbol]

  activate: (virus) ->
    if @activeVirus?
      @activeVirus.deactivate()
    @activeVirus = virus

  objectAtPoint: (point) ->
    closestObject = null
    closestDistance = 100000
    for object in @objects
      distance = object.pos.getDistance point
      if distance < closestDistance
        closestObject = object
        closestDistance = distance

    if closestDistance <= closestObject.r + 10
      closestObject
    else
      null

  objectHitsBoundary: (object) ->
    object.pos.x - object.r < 0 or
    object.pos.x + object.r > @canvas.width or
    object.pos.y - object.r < 0 or
    object.pos.y + object.r < @canvas.height

module.exports = World
