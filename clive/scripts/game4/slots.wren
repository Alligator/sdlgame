import "engine" for Draw, Asset, Trap, Fill, TileMap, CVar, Align
import "button" for Button
import "math" for Math
import "debug" for Debug
import "bagrandomizer" for BagRandomizer
import "uibutton" for TrayButton
import "soundcontroller" for SoundController
import "uibutton" for TextButton
import "random" for Random

class SlotMachine {
  construct new(td, x, y) {
    _td = td
    _x = x
    _y = y
    _w = 320
    _h = 96
    _time = 0
    _reels = [0,0,0]
    _reelCount = 9
    _spinning = false
    _nextSpinTime = 0
    _stopTime = 0

    _coinsPerWin = 9

    _icons = Asset.create(Asset.Sprite, "slotsicons", "gfx/game4/slots.png")
    _bg = Asset.create(Asset.Image, "slots_bg", "gfx/game4/slots_bg.png")
    Asset.spriteSet(_icons, 32, 32, 0, 0)
    _spinButton = TextButton.new("spin", _x+_w-128, _y+32-4, 32*3, 40, "Spin")

    _spinSound = Asset.create(Asset.Sound, "slots_spin", "sound/slots_spin.ogg")
    _winSound = Asset.create(Asset.Sound, "slots_win", "sound/slots_win.ogg")

    _rnd = Random.new()
  }

  update(dt) {
    _time = _time + dt
    var mouse = Trap.mousePosition()

    _spinButton.update(dt, mouse[0], mouse[1])
    if (_spinButton.clicked(mouse[0], mouse[1])) {
      SoundController.playOnce(_spinSound, 2.0, 0, false)
      _spinning = true
      _stopTime = _time + 4
      var base = _rnd.int(0,_reelCount)
      var offset = _rnd.int(1,4)
      for (i in 0..._reels.count) {
        _reels[i] = (base + offset * i) % _reelCount
      }
    }

    if (_spinning && _time >= _nextSpinTime) {
      for (i in 0..._reels.count) {
        _reels[i] = (_reels[i] + 1) % _reelCount
      }
      _nextSpinTime = _time + 0.08
    }

    if (_spinning && _time >= _stopTime) {
      SoundController.stopAsset(_spinSound)
      _spinning = false
      _won = _rnd.int(0, 100) >= 40
      if (_won) {
        SoundController.playOnce(_winSound)
        var icon = _rnd.int(0,_reelCount)
        for (i in 0..._reels.count) {
          _reels[i] = icon
        }

        _td.currencies[0] = _td.currencies[0] + _coinsPerWin
      }
    }
  }

  draw() {
    Draw.setColor(254, 174, 52, 255)
    Draw.rect(_x, _y, _w, _h, Fill.Solid)
    Draw.setColor(255, 255, 255, 255)
    Draw.image(_bg, _x, _y)
    for (i in 0..._reels.count) {
      Draw.sprite(_icons, _reels[i], _x+36+(32*i), _y+32)
    }

    _spinButton.draw()
  }
}