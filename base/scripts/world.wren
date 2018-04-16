import "engine" for Trap, Button, Draw, Asset, Fill, Color, TileMap
import "debug" for Debug
import "collision" for TileCollider
import "camera" for Camera
import "entities" for LevelExit, Coin, MovingPlatform, FallingPlatform, Spring, Spike, Cannon, Flame
import "player" for Player

class Level {
   w { _w }
   h { _h }
   tw { _tw }
   th { _th }
   maxX { _maxX }
   maxY { _maxY }
   layers { _layers }
   worldLayer { _worldLayer }
   backgroundColor { _backgroundColor }

   construct new(mapName) {
      TileMap.load(mapName)
      var mapProps = TileMap.getMapProperties()

      _w = mapProps["width"]
      _h = mapProps["height"]
      _tw = mapProps["tileWidth"]
      _th = mapProps["tileHeight"]
      _maxX = _w * _tw
      _maxY = _h * _th
      _layers = TileMap.layerNames()

      _worldLayer = TileMap.layerByName("world")
      if (_worldLayer == -1) {
         Trap.error(2, "can't find layer named world")
         return
      }

      var rgba = mapProps["backgroundColor"]
      _backgroundColor = [(rgba>>16)&0xFF, (rgba>>8)&0xFF, (rgba)&0xFF, (rgba>>24)&0xFF]
   }

   getTile(x, y) {
      if (x < 0 || x > _w) {
         return 1
      }

      if (y < 0 || y > _h) {
         return 0
      }

      return TileMap.getTile(_worldLayer, x, y)
   }

   objects() {
      var merged = []

      for (layer in _layers) {
         var id = TileMap.layerByName(layer)
         var objects = TileMap.objectsInLayer(id)
         for (obj in objects) {
            merged.add(obj)
         }
      }

      return merged
   }
}

class World {
   ticks { _ticks }
   tileCollider { _tileCollider }
   cam { _cam }
   entities { _entities }
   level { _level }
   coins { _coins }
   coins=(c) { _coins = c }
   totalCoins { _totalCoins }
   totalCoins=(c) { _totalCoins = c }
   drawHud { _drawHud }
   drawHud=(b) { _drawHud = b }
   player { _player }
   spr { _spr }
   
   construct new(mapName) {
      _getTile = Fn.new { |x, y| _level.getTile(x, y) }
      _level = Level.new(mapName)
      _tileCollider = TileCollider.new(_getTile, _level.tw, _level.th)
      _entities = []
      _coins = 0
      _totalCoins = 0
      _ticks = 0
      _drawHud = true
      _cam = Camera.new(8, 8, 320, 180)
      _cam.constrain(0, 0, _level.maxX, _level.maxY)
      
      var objects = _level.objects()

      var entmappings = {
         "Player": Player,
         "LevelExit": LevelExit,
         "Coin": Coin,
         "MovingPlatform": MovingPlatform,
         "FallingPlatform": FallingPlatform,
         "Spring": Spring,
         "Spike": Spike,
         "Cannon": Cannon,
         "Flame": Flame,
      }

      for (obj in objects) {
         var eType = entmappings[obj["type"]]
         if (eType != null) {
            // FIXME: 2nd param, ti, unneeded
            var ent = eType.new(this, 1, obj["x"], obj["y"] - level.th)
            if (ent is Player) {
               _entities.insert(0, ent)
               _player = ent
            } else {
               _entities.add(ent)
            }
         }
      }

      var sprites = Asset.create(Asset.Image, "sprites", "maps/tilesets/plat.gif")

      Asset.loadAll()

      _spr = Asset.createSprite(sprites, 8, 8, 0, 0)

   }

   update(dt) {
      _ticks = _ticks + dt
      Debug.text("world", "time", _ticks)
      Debug.text("world", "ents", _entities.count)

      for (ent in _entities) {
         if (ent.active) {
            ent.think(1/60)
         }
      }

      for (i in _entities.count-1..0) {
         if (_entities[i].active == false) {
            _entities.removeAt(i)
         }
      }
   }

   draw(w, h) {
      Draw.clear()
      Draw.resetTransform()

      Draw.setColor(Color.Fill, level.backgroundColor)
      Draw.rect(0, 0, w, h, Fill.Solid)

      Draw.transform(h / _cam.h, 0, 0, h / _cam.h, 0, 0)
      Draw.translate(0 - _cam.x, 0 - _cam.y)

      for (i in 0..level.layers.count-1) {
         Draw.mapLayer(i)
      }

      for (ent in _entities) {
         if (ent.active) {
            ent.draw(_ticks)
         }
      }

      Draw.submit()

      /*
      if (_drawHud && _player != null) {
         TIC.rect(0, 0, 240, 12, 1)
         if (_totalCoins > 0) {
            TIC.spr(256, 100, 1, 0)
            TIC.print("%(_coins)/%(_totalCoins)", 110, 3, _coins == _totalCoins ? 14 : 15, true)
         }
         TIC.print("S", 4, 3, 15, true)

         for (i in 0..2) {
            TIC.spr(i < _player.health ? 265 : 281, 198+(i*14), 2, 0, 1, 0, 0, 2, 1)
         }

         var pct = (_player.pMeter / _player.pMeterCapacity * 40 / 8).floor
         for (i in 0..4) {
            TIC.spr(i < pct ? 283 : 267, 11 + i * 6, 2, 0)
         }
      }
      */
   }

   shutdown() {

   }
}