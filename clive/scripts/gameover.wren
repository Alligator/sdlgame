import "engine" for Draw, Trap, Asset
import "button" for Button

class GameOver {
  nextScene { _nextScene }

  construct new(params) {
    _nextScene = null
    _time = 0
    _scale = 4

    _mapName = params["map"]
    _mode = params["mode"]

    _font = Asset.create(Asset.Font, "speccy", "fonts/spectrum.ttf")
    // TODO: should this be passed in? are we gonna re-use this game over?
    _spr = Asset.create(Asset.Sprite, "spr", "maps/tilesets/e%(_mode).png")
    if (_mode != 4) {
      _sprite = Asset.create(Asset.Image, "goat", "gfx/game1/goat.png")
      Asset.spriteSet(_spr, 8, 8, 0, 0)
      _sizeScale = 1
    } else {
      _sprite = Asset.create(Asset.Image, "goat", "gfx/game4/goat.png")
      Asset.spriteSet(_spr, 32, 32, 0, 0)
      _sizeScale = 0.25
    }

    Asset.loadAll()

    _imgSize = Asset.imageSize(_sprite)
  }

  shutdown() {
  }

  update(dt) {
    _time = _time + dt

    if (Trap.buttonPressed(Button.Click, 0, -1)) {
      _nextScene = ["td", _mapName]
    }
  }

  textColor() {
    var idx = ((_time * 12) % 16).floor
    var l = idx & 1
    var b = (idx & 2) >> 1
    var g = (idx & 4) >> 2
    var r = (idx & 8) >> 3

    var mul = l > 0 ? 255 : 192
    return [r * mul, g * mul, b * mul, 255]
  }

  drawCenteredText(x, y, string) {
    var width = string.count * 8
    Draw.text(x - width/2 , y, 800, string)
  }

  draw(w, h) {
    Draw.scale(_scale)
    w = w/4
    h = h/4

    Draw.setTextStyle(_font, 20)
    Draw.setColor(textColor())
    var y = h/2 + 48
    drawCenteredText(w/2 , y, "THE POUND HAS COLLAPSED")
    y = y + 16
    drawCenteredText(w/2 , y, "GAME OVER")

    Draw.setColor(255, 255, 0, 255)
    y = y + 16
    drawCenteredText(w/2, y, "Please try again")

    Draw.setColor(255, 255, 255, 255)
    Draw.sprite(_spr, 8, w/2 - 8, h/2 - 32, 1 * _sizeScale, 0, 2, 2)

    for (i in 0...8) {
      var rad = (i * ((Num.pi*2) / 8)) + _time
      var radius = 48
      var goatX = w/2 + rad.cos * radius - 8
      var goatY = (h/2 - 24) + rad.sin * radius - 8
      goatX = goatX - (goatX % 8)
      goatY = goatY - (goatY % 8)
      // Draw.rect(w/2 + rad.cos * radius, h/3 + rad.sin * radius, 8, 8, false)
      Draw.image(_sprite, goatX, goatY, _imgSize[0], _imgSize[1], 1.0 * _sizeScale)
    }
  }
}