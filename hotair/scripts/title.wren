import "engine" for Draw, Asset, TileMap, Trap, Fill, Align
import "button" for Button
import "soundcontroller" for SoundController
import "random" for Random
import "math" for Math
import "levels" for Levels
import "timer" for Timer

class Title {
  nextScene { _nextScene }
  nextScene=(params) { _nextScene = params }

  construct new(params) {
    _font = Asset.create(Asset.BitmapFont, "font", "gfx/font.png")
    Asset.bmpfntSet(_font, "abcdefghijklmnopqrstuvwxyz!?'$1234567890", 0, 1, 2, 5)

    _iconbg = Asset.create(Asset.Image, "iconbg", "gfx/icon-background.png")

    _icons = Asset.create(Asset.Sprite, "icons", "gfx/icons.png")
    Asset.spriteSet(_icons, 16, 16, 0, 0)
    _iconCount = 15

    _logo = Asset.create(Asset.Image, "hotair", "gfx/hotair.png")

    _select = Asset.create(Asset.Sound, "select", "sound/select.wav")
    _menuMove = Asset.create(Asset.Sound, "menuMove", "sound/menumove.wav")
    _bgm = Asset.create(Asset.Sound, "bgm", "sound/menu.ogg")

    Asset.loadAll()

    _rnd = Random.new()

    _selectedItem = 0
    _selectedLevel = 0
    _currentIcon = 0
    _cycle = 0
    _t = 0

    _items = [
      "start",
      "endless mode",
      "help",
    ]

    if (Trap.getPlatform() != "emscripten") {
      _items.add("quit")
    }

    _actions = [
      Fn.new {
        nextScene = _selectedLevel == 0 ? ["cutscene", "game"] : ["game", _selectedLevel]
      },

      Fn.new {
        nextScene = ["game", "endless"]
      },

      Fn.new {
        nextScene = "help"
      },

      Fn.new {
        Trap.console("quit")
      }
    ]

    _snow = []

    SoundController.playMusic(_bgm)
  }

  update(dt) {
    _t = _t + dt

    _cycle = _t / 4 % 32
    if (_cycle == 0) {
      _currentIcon = (_currentIcon + 1) % _iconCount
    }

    if (_t % 4 == 0) {
      // x, y, dx
      _snow.add([_rnd.int(320), 0, 0])
    }

    for (s in _snow) {
      s[1] = s[1] + dt
      s[2] = ((_t + s[0]) / 16).sin * 2
      s[0] = Math.lerp(s[0], s[0] + s[2], 0.1)
    }

    _snow = _snow.where{|s| s[1] < 180 }.toList

    var confirmed = Trap.buttonPressed(Button.Start, 0, -1) || Trap.buttonPressed(Button.Flap, 0, -1)
    var up = Trap.buttonPressed(Button.Up, 0, -1)
    var down = Trap.buttonPressed(Button.Down, 0, -1)
    var left = Trap.buttonPressed(Button.Left, 0, -1)
    var right = Trap.buttonPressed(Button.Right, 0, -1)

    if (up) {
      _selectedItem = _selectedItem - 1
      if (_selectedItem < 0) {
        _selectedItem = _items.count - 1
      }
      SoundController.playOnce(_menuMove, 0.5, 0, false)
    } else if (down) {
      _selectedItem = (_selectedItem + 1) % _items.count
      SoundController.playOnce(_menuMove, 0.5, 0, false)
    } else if ((left || right) && _items[_selectedItem] == "start") {
      _selectedLevel = right ? (_selectedLevel + 1) % Levels.Levels.count : _selectedLevel == 0 ? Levels.Levels.count - 1 : _selectedLevel - 1
      SoundController.playOnce(_menuMove, 0.5, 0, false)
    } else if (confirmed) {
      SoundController.playOnce(_select, 0.5, 0, false)
      Timer.runLater(30) {
        _actions[_selectedItem].call()
      }
    }
  }

  draw(w, h) {
    Draw.clear()
    Draw.resetTransform()
    Draw.scale(h / 180)

    // grid squares
    Draw.setColor(17, 94, 51, 255)
    Draw.rect(0, 0, w, h, Fill.Solid)

    Draw.setColor(115, 41, 48, 255)

    var x = -32 + (_t / 2) % 64
    var y = -32 + (_t / 8) % 64
    while (x < w) {
      var innerY = y
      while (innerY < h) {
        Draw.rect(x, innerY, 32, 32, Fill.Solid)
        Draw.rect(x-32, innerY-32, 32, 32, Fill.Solid)
        innerY = innerY + 64
      }
      x = x + 64
    }

    for (s in _snow) {
      Draw.setColor(178, 220, 239, 255)
      Draw.rect(s[0], s[1], 2, 2, false)
      Draw.setColor(255, 255, 255, 255)
      Draw.rect(s[0] + 1, s[1], 1, 1, false)
    }

    //icon strip
    Draw.setColor(0, 0, 0, 150)
    Draw.rect(0, 0, w, 29, Fill.Solid)
    Draw.rect(0, 180-29, w, 29, Fill.Solid)

    Draw.setColor(255, 255, 255, 255)

    x = -32
    var topIcon = _currentIcon
    var bottomIcon = _currentIcon
    while (x <= w / (h/180)) {
      Draw.sprite(_icons, 16, x - _cycle, 5, 1.0, 1.0, 0, 2, 2)
      Draw.sprite(_icons, topIcon, x - _cycle +3, 5+1)

      Draw.sprite(_icons, 16, x + _cycle, 156, 1.0, 1.0, 0, 2, 2)
      Draw.sprite(_icons, bottomIcon, x + _cycle +3, 156+1)

      x = x + 32
      topIcon = (topIcon + 1) % _iconCount
      bottomIcon = bottomIcon == 0 ? _iconCount - 1 : bottomIcon - 1
    }

    Draw.image(_logo, 320/2 - 80, 38, 0, 0, 1.0, 1.0)

    Draw.setTextStyle(_font, 1.0, 1.0, Align.Center)
    Draw.text(0, 78, 320, "a game for the 2018 awful holiday jam")

    for (i in 0..._items.count) {
      var item = _items[i]
      if (item == "start") {
        item = item + " level %(_selectedLevel + 1)"
      }
      Draw.setColor(i == _selectedItem ? [163, 206, 39, 255] : [255, 255, 255, 255])
      Draw.text(0, i*10 + 99, 320, item)
    }

    Draw.setColor(255, 255, 255, 255)
  }

  shutdown() {
    Asset.clearAll()
  }
}