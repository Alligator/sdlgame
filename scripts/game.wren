import "engine" for Draw, Asset, TileMap, Trap, Button
import "math" for Math
import "camera" for Camera

import "player" for Player
import "mine" for Mine

class Game {
   nextScene { _nextScene }
   nextScene=(params) { _nextScene = params }

   entities { _entities }
   cam { _cam }
   launched { _launched }
   launched=(b) { _launched = b }

   construct new(params) {
      _icons = Asset.create(Asset.Sprite, "icons", "gfx/icons.png")
      Asset.spriteSet(_icons, 16, 16, 0, 0)

      _entities = []

      _entities.add(Player.new(this, {}, 220, 50, 16, 16))
      _entities.add(Mine.new(this, {"sprite": _icons}, 64, 64, 16, 16))

      _cam = Camera.new(16, 16, 320, 180)
      _scrollX = 0
      _launched = false

      Asset.loadAll()
   }

   update(dt) {
      if (_launched) {
         _scrollX = _scrollX - 0.25
         // TODO: do we want to floor this?
         _cam.move(_scrollX, 0)
      }

      for (ent in _entities) {
         ent.think(dt)
         if (ent.x > _cam.x + _cam.w) {
            ent.die()
         }
      }

      _entities = _entities.where {|c| !c.dead }.toList
   }

   draw(w, h) {
      Draw.clear()
      Draw.resetTransform()
      Draw.scale(h / _cam.h)

      Draw.translate(-_cam.x, -_cam.y)

      for (ent in _entities) {
         ent.draw()
      }
   }

   shutdown() {
      Asset.clearAll()
   }  
}