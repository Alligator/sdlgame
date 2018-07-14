import "engine" for Draw, Asset, Trap, Color, Fill, Button, TileMap, CVar
import "math" for Math
import "debug" for Debug
import "bagrandomizer" for BagRandomizer
import "uibutton" for UIButton

class PieceTray {
   construct new (td, x, y, w, h) {
      _td = td
      _x = x
      _y = y
      _w = w
      _h = h

      _buttons = [
         UIButton.new("tower1", x+0, y+8, 16, 16),
         UIButton.new("tower2", x+24, y+8, 16, 16),
         UIButton.new("grass", x+24, y+32, 16, 16),
         UIButton.new("piece1", x+8, y+56+32*0, 24, 24),
         UIButton.new("piece2", x+8, y+56+32*1, 24, 24),
         UIButton.new("piece3", x+8, y+56+32*2, 24, 24),
         UIButton.new("piece4", x+8, y+56+32*3, 24, 24)
      ]

      _pieces = [
         [1,1,0, // U
          0,1,0,
          1,1,0],

         [1,1,1, // big T
          0,1,0,
          0,1,0],

         [0,0,0, // T
          1,1,1,
          0,1,0],

         [0,1,0, // 3x1
          0,1,0,
          0,1,0],

         [0,1,0, // 2x1
          0,1,0,
          0,0,0],

         [0,0,0, // 1x1
          0,1,0,
          0,0,0],

         [0,1,0, // corner
          1,1,0,
          0,0,0],

         [0,0,1, // big Z
          1,1,1,
          1,0,0],

         [0,1,0, // Z
          1,1,0,
          1,0,0],

         [1,0,0, // S
          1,1,0,
          0,1,0],

         [0,1,0, // J
          0,1,0,
          1,1,0],

         [0,1,0, // L
          0,1,0,
          1,1,0],

      ]

      _pieceGen = BagRandomizer.new(_pieces.count)
      _queuedPieces = [null, null, null, null]
      _activeTool = null
   }

   update(dt) {
      var mouse = Trap.mousePosition()

      for (i in (0..._queuedPieces.count)) {
         if (_queuedPieces[i] == null) {
            _queuedPieces[i] = _pieces[_pieceGen.next()]
         }
      }

      for (button in _buttons) {
         if (button.clicked(mouse[0] / _td.scale, mouse[1] / _td.scale)) {
            _activeTool = button.id
         }
      }
   }

   drawPiece(centerX, centerY, piece) {
      for (i in 0...9) {
         var x = centerX + (i%3) * 8 - 8
         var y = centerY + (i/3).floor * 8 - 8

         if (piece[i] > 0) {
            Draw.sprite(_td.spr, 4, x, y)
         }
      }
   }

   draw() {
      // Draw.translate(_x, _y)

      Draw.setColor(Color.Stroke, 255, 255, 0, 255)
      // Draw.rect(0, 0, _w, _h, Fill.Outline)

      // draw gold (number of currencies are game dependent, pass in from TD)

      for (button in _buttons) {
         button.draw()

         if (button.id == "tower1") {
            Draw.sprite(_td.spr, 0, button.x, button.y, 1, 1, 0, 2, 2)

         } else if (button.id == "tower2") {
            Draw.sprite(_td.spr, 2, button.x, button.y, 1, 1, 0, 2, 2)

         } else if (button.id == "grass") {
            Draw.sprite(_td.spr, 22, button.x, button.y, 1, 1, 0, 2, 2)
         } else if (button.id == "piece1") {
            drawPiece(button.x+8, button.y+8, _pieces[0])
         } else if (button.id == "piece2") {
            drawPiece(button.x+8, button.y+8, _pieces[1])
         } else if (button.id == "piece3") {
            drawPiece(button.x+8, button.y+8, _pieces[2])
         } else if (button.id == "piece4") {
            drawPiece(button.x+8, button.y+8, _pieces[3])
         }

      }

      // Draw.translate(-_x, -_y)
   }
}