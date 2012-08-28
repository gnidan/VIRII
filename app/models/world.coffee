_ = require 'underscore'

class World
  constructor: (@canvas, @parent) ->
    @objects = []
    @length = 0
    @viruses = []
    @cells = []
    @activeVirus = null
    @items = []

  numCells: () ->
    @cells.length

  numInfectedCells: () ->
    infectedCells = _.filter @cells, (cell) ->
      cell.isInfected()
    infectedCells.length

  numViruses: () ->
    @viruses.length

  printInfo: () ->
    console.log "Cells: " + @numCells()
    console.log "Viruses: " + @numViruses()
    console.log "Infected Cells: " + @numInfectedCells()

  add: (object) ->
    @objects.push object
    @length += 1

    if object.isCell()
      @cells.push object

    if object.isVirus()
      @viruses.push object

    @items[object.placedSymbol] = object

  remove: (object) ->
    @objects = _.without @objects, object
    @length = @objects.length

    if object.isCell()
      @cells = _.without @cells, object

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
