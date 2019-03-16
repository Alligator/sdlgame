import "random" for Random
import "engine" for Draw, Asset, TileMap, Trap
import "button" for Button
import "math" for Math
import "actionqueue" for ActionQueue
import "soundcontroller" for SoundController

class Cutscene {
  nextScene { _nextScene }
  nextScene=(params) { _nextScene = params }

  construct new(nextScene) {
    _uncle = Asset.create(Asset.Sprite, "uncle", "gfx/uncle.png")
    _lady = Asset.create(Asset.Sprite, "lady", "gfx/lady.png")
    _guy = Asset.create(Asset.Sprite, "guy", "gfx/guy.png")

    _font = Asset.create(Asset.BitmapFont, "font", "gfx/font.png")
    Asset.bmpfntSet(_font, "abcdefghijklmnopqrstuvwxyz!?'$1234567890", 0, 1, 2, 5)

    Asset.spriteSet(_uncle, 16, 48, 0, 0)
    Asset.spriteSet(_lady, 16, 48, 0, 0)
    Asset.spriteSet(_guy, 16, 48, 0, 0)

    _icons = Asset.create(Asset.Sprite, "icons", "gfx/icons.png")
    Asset.spriteSet(_icons, 16, 16, 0, 0)
    _iconCount = 15

    _bubble = Asset.create(Asset.Image, "bubble", "gfx/bubble.png")

    _bgm = Asset.create(Asset.Sound, "bgm", "sound/cutscene.ogg")

    _rnd = Random.new()
    _paramNextScene = nextScene
    _canSkip = false

    var y = 120
    _uncleState = {
      "x": 152,
      "y": y,
      "yelling": false,
      "scale": 1.0,
      "icon": _rnd.int(_iconCount)
    }
    _scareds = [
      ScaredEntity.new(_lady, 132, y, 1),
      ScaredEntity.new(_guy, 172, y, -1)
    ]

    _queue = ActionQueue.new([
      [50, Fn.new {
        _uncleState["yelling"] = true
        _uncleState["icon"] = (_uncleState["icon"] + 1) % _iconCount
        for (scared in _scareds) {
          scared.scare(16)
        }
      }],
      [100, Fn.new { _uncleState["yelling"] = false }],
      [50, Fn.new {
        _uncleState["yelling"] = true
        _uncleState["icon"] = (_uncleState["icon"] + 1) % _iconCount
        _uncleState["scale"] = 2.0
        for (scared in _scareds) {
          scared.scare(32)
        }
      }],
      [100, Fn.new { _uncleState["yelling"] = false }],
      [50, Fn.new {
        _uncleState["yelling"] = true
        _uncleState["icon"] = (_uncleState["icon"] + 1) % _iconCount
        _uncleState["scale"] = 3.0
        for (scared in _scareds) {
          scared.scare(256)
        }
      }],
      [100, Fn.new { _uncleState["yelling"] = false }],
      [150, Fn.new { _nextScene = nextScene }],
    ])

    _t = 0

    Asset.loadAll()

    SoundController.playOnce(_bgm)
  }

  update(dt) {
    _t = _t + dt
    for (scared in _scareds) {
      scared.update(dt)
    }
    _queue.update(dt)

    if (Trap.buttonPressed(Button.Start, 0, -1)) {
      _nextScene = _paramNextScene
    }
  }

  drawCenteredText(font, x, y, text) {
    var w = Asset.textWidth(font, text)
    Draw.bmpText(font, x - w/2, y, text)
  }

  draw(w, h) {
    Draw.clear(0, 0, 0, 255)
    Draw.resetTransform()
    Draw.scale(h / 180)

    for (scared in _scareds) {
      scared.draw(w, h)
    }

    drawCenteredText(_font, 320/2, 10, "now it is the beginning of a")
    drawCenteredText(_font, 320/2, 20, "nightmare christmas dinner! let us")
    drawCenteredText(_font, 320/2, 30, "try to get out of this conversation!")
    drawCenteredText(_font, 320/2, 40, "good luck!")

    Draw.sprite(
      _uncle,
      _uncleState["yelling"] ? (_t / 12) % 2 : 0,
      _uncleState["x"],
      _uncleState["y"])

    if (_uncleState["yelling"]) {
      Draw.image(
        _bubble,
        _uncleState["x"] + 16,
        _uncleState["y"] - 17 - (24 * (_uncleState["scale"] - 1)),
        0, 0, _uncleState["scale"])
      Draw.sprite(
        _icons,
        _uncleState["icon"],
        _uncleState["x"] + 16 + (6 * _uncleState["scale"]),
        _uncleState["y"] - 14 - (22 * (_uncleState["scale"] - 1)),
        _uncleState["scale"])
    } else {
    }
  }

  shutdown() {
    Asset.clearAll()
  }
}

class ScaredEntity {
  construct new(sprite, x, y, dir) {
    _spr = sprite

    _x = x
    _y = y
    _dir = dir

    _xTarget = _x

    _t = 0
    _rnd = Random.new()
  }

  scare(offset) {
    _xTarget = _x - (offset * _dir)
  }

  update(dt) {
    _t = _t + dt

    var t = dt * 0.1
    _x = (1 - t) * _x + t * _xTarget
  }

  draw(w, h) {
    var diff = (_x - _xTarget).abs
    Draw.sprite(_spr, diff > 0.1 ? 1 : 0, _x, _y)
  }
}