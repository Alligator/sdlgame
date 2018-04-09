import "engine" for Trap, Button, Draw, Scene, Asset, Fill, Color, TileMap
import "dialog" for Dialog, DialogManager

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

    var dialogs = _mapObj.where {|obj| obj["type"] == "dialog" }
    _dialogManager = DialogManager.new(dialogs, _font)

    _npcs = _mapObj.where {|obj| obj["type"] == "npc" }

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

    if (_showBlood) {
      var r = (_frameTime * 1.5).sin.abs * 80
      _bgColor = [r, 0, 0]
    } else {
      _bgColor = [0, 0, 0]
    }

    _frameTime = _frameTime + dt

    _dialogManager.update(dt, _player)
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
    Draw.transform(
      h / 180, 0, shear,
      h / 180, xoff, yoff
      )

    if (_showBlood) {
      Draw.rotate((_frameTime * 2).sin/80)
    }

    Draw.transform(
      1, 0, 0,
      1, -xoff/4, -yoff/4
      )
    Draw.translate(35/2, 20/2)

    Draw.mapLayer(_bgLayer)
    Draw.mapLayer(_collideLayer)

    if (_showBlood) {
      Draw.mapLayer(_bloodLayer)
    }

    Draw.sprite(_spr, 0, _player["x"], _player["y"])

    for (npc in _npcs) {
      var sprId = Num.fromString(npc["properties"]["sprite"])
      Draw.sprite(_spr, sprId, npc["x"], npc["y"])
    }

    Draw.mapLayer(_fgLayer)

    _dialogManager.draw(_player)

    Draw.setColor(Color.Fill, 255, 0, 0, 255)
    Draw.setColor(Color.Stroke, 255, 255, 0, 255)
    Draw.rect(10, 10, 10, 10, false)
    Draw.rect(10, 10, 10, 10, true)

    Draw.rect(30, 10, 0.01, 10, false)
    Draw.rect(30, 10, 0.01, 10, true)

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
