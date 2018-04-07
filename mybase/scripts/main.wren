import "engine" for Trap, Button, Draw, Scene, Asset, Fill, Color, TileMap

class Game is Scene {
  construct new(mapName) {
    TileMap.load("maps/map.tmx")

    _sprites = Asset.create(Asset.Image, "sprites", "gfx/ghosts.png")
    _font = Asset.create(Asset.BitmapFont, "font", "gfx/font.png")
    Asset.bmpfntSet(_font, "abcdefghijklmnopqrstuvwxyz'", 2, 8, 8)

    Asset.loadAll()

    _bgLayer = TileMap.layerByName("bg")
    _fgLayer = TileMap.layerByName("fg")
    _bloodLayer = TileMap.layerByName("blood")
    _collideLayer = TileMap.layerByName("collide")

    _spr = Asset.createSprite(_sprites, 8, 8, 0, 0)
    _mapObj = TileMap.objectsInLayer(TileMap.layerByName("objects"))

    Trap.printLn(_mapObj)

    _player = {
      "x": 200,
      "y": 100,
    }
    _playerMoveSpeed = 48
    _ignoreBlood = false
    _showBlood = false

    _currentDialog = null
    _bgColor = []
    _frameTime = 0
  }

  update(dt) {
    var repeatSpeed = 1000/30 
    var newPlayerX = _player["x"]
    var newPlayerY = _player["y"]
    var spd = _playerMoveSpeed * dt

    if (Trap.keyActive(Button.Down)) {
      newPlayerY = newPlayerY + spd
    }

    if (Trap.keyActive(Button.Up)) {
      newPlayerY = newPlayerY - spd
    }

    if (Trap.keyActive(Button.Right)) {
      newPlayerX = newPlayerX + spd
    }

    if (Trap.keyActive(Button.Left)) {
      newPlayerX = newPlayerX - spd
    }

    var playerTileX = newPlayerX / 8
    var playerTileY = newPlayerY / 8

    var tile = TileMap.getTile(_collideLayer, playerTileX, playerTileY)
    if (tile > 0) {
      // Trying to move into a tile, reset the move
      newPlayerX = _player["x"]
      newPlayerY = _player["y"]
      playerTileX = newPlayerX / 8
      playerTileY = newPlayerY / 8
    }

    _player["x"] = newPlayerX
    _player["y"] = newPlayerY

    // See if we're in any dialog
    var objs = _mapObj.where {|obj|
      var inX = _player["x"] > obj["x"] && _player["x"] < obj["x"] + obj["width"]
      var inY = _player["y"] > obj["y"] && _player["y"] < obj["y"] + obj["height"]
      return inX && inY
    }

    if (objs.count > 0) {
      _currentDialog = objs.toList[0]
      if (_currentDialog["name"] == "blood" && !_ignoreBlood) {
        _showBlood = !_showBlood
        _frameTime = 0
        _ignoreBlood = true
      }
    } else {
      _ignoreBlood = false
      _currentDialog = null
    }

    if (_showBlood) {
      var r = (_frameTime * 1.5).sin.abs * 80
      _bgColor = [r, 0, 0]
    } else {
      _bgColor = [0, 0, 0]
    }

    _frameTime = _frameTime + dt
  }

  drawCurrentDialogText() {
    var text = _currentDialog["properties"]["text"]
    var width = Asset.measureBmpText(_font, text)
    Draw.setColor(Color.Fill, 0, 0, 0, 255)
    Draw.setColor(Color.Stroke, 255, 255, 255, 255)
    Draw.rect(_player["x"] - width/2 - 2, _player["y"] - 21, width + 2, 11, false)
    Draw.rect(_player["x"] - width/2 - 2, _player["y"] - 21, width + 2, 11, true)
    Draw.bmpText(_font, _player["x"] - width/2, _player["y"] - 20, text)
  }

  draw(w, h) {
    Draw.clear()

    Draw.setColor(Color.Fill, _bgColor[0], _bgColor[1], _bgColor[2], 255)
    Draw.rect(0, 0, w, h, false)

    // map width = 35
    // map height = 20
    var xoff = w/2
    var yoff = h/2
    var shear = _showBlood ? _frameTime.sin/12 : 0
    Draw.setTransform(
      h / 180, 0, shear,
      h / 180, xoff, yoff,
      true)

    if (_showBlood) {
      Draw.rotate((_frameTime * 2).sin/80)
    }

    Draw.setTransform(
      1, 0, 0,
      1, -xoff/4, -yoff/4,
      false)
    Draw.translate(35/2, 20/2)

    Draw.mapLayer(_bgLayer)
    Draw.mapLayer(_collideLayer)

    if (_showBlood) {
      Draw.mapLayer(_bloodLayer)
    }

    Draw.sprite(_spr, 0, _player["x"], _player["y"])

    Draw.mapLayer(_fgLayer)

    if (_currentDialog != null) {
      drawCurrentDialogText()
    }

    Draw.submit()
  }

  shutdown() {
    TileMap.free()
    Asset.clearAll()
  }
}

  class Main {
    static scene { __scene }

    static init(mapName) {
      __scene = Game.new(mapName)
    }

    static update(dt) {
      __scene.update(dt)
    }

    static draw(w, h) {
      __scene.draw(w, h)
    }

    static shutdown() {
      __scene.shutdown()
      __scene = null
    }
  }
