import "engine" for Asset, Draw, Color, Trap
import "util" for Util

class DialogManager {
  construct new(dialogs, font) {
    _font = font
    _dialogs = dialogs.map{|obj| 
      return Dialog.new(obj["properties"]["text"], _font, obj)
    }.toList
  }

  update(dt, player) {
    for (dialog in _dialogs) {
      dialog.update(dt, player)
    }
  }

  draw(player) {
    for (dialog in _dialogs) {
      if (dialog.isOpen()) {
        dialog.draw()
      }
    }
  }
}

class Dialog {
  construct new(text, font, obj) {
    _text = text
    _font = font
    _obj = obj

    _x = obj["x"]
    _y = obj["y"]

    _width = Asset.measureBmpText(_font, _text)
    _expandTimer = 0.2 
    _timer = _expandTimer
    _open = false
    Trap.printLn("cunt")
  }

  isOpen() {
    return _open || (_timer < _expandTimer)
  }

  update(dt, player) {
    _timer = _timer + dt

    if (_open) {
      Trap.printLn("update " + _timer.toString)
    }

    var inX = player["x"] > _obj["x"] && player["x"] < _obj["x"] + _obj["width"]
    var inY = player["y"] > _obj["y"] && player["y"] < _obj["y"] + _obj["height"]
    var inside = inX && inY

    if (inside && !_open) {
      Trap.printLn("opening")
      _open = true
      _timer = 0
    }

    if (!inside && _open) {
      Trap.printLn("closing")
      _timer = 0
      _open = false
    }
  }

  draw() {
    if (!_open && _timer >= _expandTimer) {
      return
    }

    var width = _width
    Trap.printLn("draw " + _timer.toString)
    if (_timer < _expandTimer) {
      var t = _timer/_expandTimer
      width = _open ? Util.lerp(0, _width, t) : Util.lerp(_width, 0, t) 
    }

    Draw.setColor(Color.Fill, 0, 0, 0, 255)
    Draw.setColor(Color.Stroke, 255, 255, 255, 255)
    Draw.rect(_x - width/2 - 2, _y - 21, width + 2, 11, false)
    Draw.rect(_x - width/2 - 2, _y - 21, width + 2, 11, true)

    if (_open && _timer >= _expandTimer) {
      Draw.bmpText(_font, _x - width/2, _y - 20, _text)
    }
  }
}