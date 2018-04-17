import "timer" for Timer
import "engine" for Draw, Asset, TileMap, Trap

class Intro {
   nextScene { _nextScene }
   nextScene=(params) { _nextScene = params }

   construct new(mapName) {
      TileMap.load(mapName)
      var mapProps = TileMap.getMapProperties()

      _nextScene = null

      _title = mapProps["properties"]["title"]

      _font = Asset.create(Asset.BitmapFont, "font", "gfx/good_neighbors.png")
      Asset.bmpfntSet(_font, "!\"#$\%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~", 0, -1, 7, 16)

      _fixedFont = Asset.create(Asset.BitmapFont, "fixedfont", "gfx/panicbomber.png")
      Asset.bmpfntSet(_fixedFont, " !\"#$\%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~", 8, 0, 8, 8)

      _fixedFontBlue = Asset.create(Asset.BitmapFont, "fixedfontblue", "gfx/panicbomber_blue.png")
      Asset.bmpfntSet(_fixedFontBlue, " !\"#$\%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~", 8, 0, 8, 8)

      _music = Asset.create(Asset.Mod, "deathmusic", "music/intro.mod")

      Asset.loadAll()

      _titleLen = Asset.measureBmpText(_font, _title)

      Trap.sndPlay(_music)

      Timer.runLater(180, Fn.new {
         _nextScene = ["world", mapName]
      })
   }

   update(dt) {

   }

   draw(w, h) {
      Draw.clear()
      Draw.resetTransform()
      Draw.transform(h / 180, 0, 0, h / 180, 0, 0)

      Draw.bmpText(_fixedFont, 20, 50, "Now entering...")
      Draw.bmpText( _font, (320 - _titleLen) / 2, 85, _title)
      Draw.bmpText(_fixedFontBlue, 220, 120, "Good Luck!")

      Draw.submit()
   }

   shutdown() {

   }
}