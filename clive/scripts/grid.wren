import "engine" for Draw, Asset, Trap, Fill, TileMap, CVar, Align
import "button" for Button
import "math" for Math
import "debug" for Debug
import "fonts" for Fonts

import "entities/coin" for Coin
import "tower" for Tower

class Grid {
  entities { _entities }
  goalX { _goalX }
  goalY { _goalY }

  construct new (td, x, y, w, h, tw, th) {
    _td = td
    _x = x
    _y = y
    _w = w
    _h = h
    _tw = tw
    _th = th

    _font = Asset.create(Asset.Font, "body", Fonts.body)

    _showPathsCVar = CVar.get("debug.pathfinding", false)
    _tiles = List.filled(_w*_h, 0)
    _paths = List.filled(_w*_h, 0)
    _towers = []
    _entities = []
  }

  // needs to go from screen space -> local
  getLocalMouse() {
    var mouse = Trap.mousePosition()
    mouse[0] = mouse[0] / _td.scale - (_x  * _tw)
    mouse[1] = mouse[1] / _td.scale - (_y * _th)
    return mouse
  }

  addEntity(ent) {
    _entities.add(ent)
  }

  setTower(x, y, type) {
    _towers.add(Tower.new(_td, x, y, type))
    // reserve space on tile grid for tower, but draw invisibly
    _tiles[y*_w+x] = 200
    _tiles[y*_w+x+1] = 200
    _tiles[(y+1)*_w+x] = 200
    _tiles[(y+1)*_w+x+1] = 200
  }

  setGrass(x, y) {
    _tiles[y*_w+x] = 22
  }

  isLegal(x, y) {
    return x >= 0 && x < _w && y >= 0 && y < _h
  }

  isGrass(x,y) {
    return isLegal(x, y) ? _tiles[y*_w+x] == 22 : false
  }

  isWall(x,y) {
    if (!isLegal(x, y)) {
      return false
    }

    var tid = _tiles[y*_w+x]
    return (tid >= 4 && tid <= 7) || (tid >= 20 && tid <= 21)
  }

  isTower(x, y) {
    if (!isLegal(x, y)) {
     return false
    }

    // lazy but it's easier than checking for all 4 tiles
    return _tiles[y*_w+x] == 200
  }

  destroyGrass(x,y) {
    if (!isGrass(x,y)) {
      Debug.printLn("WARNING: tile %(x),%(y) wasn't grass")
      return
    }
    _tiles[y*_w+x] = 0
  }

  destroyWall(x,y) {
    if (!isWall(x,y)) {
      Debug.printLn("WARNING: tile %(x),%(y) wasn't a wall")
      return
    }
    _tiles[y*_w+x] = 0
  }

  destroyTower(x, y) {
    if (!isTower(x,y)) {
      Debug.printLn("WARNING: tile %(x),%(y) wasn't a tower")
      return
    }
    // find the tower for this tile
    var foundTowers = _towers.where{|tower| (tower.x == x || tower.x + 1 == x) && (tower.y == y || tower.y + 1 == y)}.toList
    if (foundTowers.count > 0) {
      var tower = foundTowers[0]
      _tiles[tower.y*_w+tower.x] = 0
      _tiles[tower.y*_w+tower.x+1] = 0
      _tiles[(tower.y+1)*_w+tower.x] = 0
      _tiles[(tower.y+1)*_w+tower.x+1] = 0
      _towers = _towers.where{|otherTower| tower.x != otherTower.x || tower.y != otherTower.y}.toList
    }
  }

  isPieceValid(x, y, piece) {
    for (py in 0...3) {
      for (px in 0...3) {
        // if the piece has a block in that position, and that cell is blocked
        if (piece[py*3+px] > 0 && isBlocked(px+x, py+y)) {
          return false
        }
      }
    }
    return true
  }

  setWallPiece(x, y, piece) {
    if (!isPieceValid(x, y, piece)) {
      return false
    }

    for (py in 0...3) {
      for (px in 0...3) {
        var tid = piece[py*3+px]
        if (tid > 0) {
          _tiles[(py+y)*_w + (px+x)] = tid
        }
      }
    }

    // TODO: probably setup the proper wall transitions here

    return true
  }

  update(dt) {
    // if right click, deselect the current piece
    if (!_td.paused && _td.pieceTray.activeTool && _td.pieceTray.activeTool.category != "piece" && Trap.buttonPressed(Button.Rotate, 0, -1)) {
      _td.pieceTray.deselectPiece()
    }

    var localMouse = getLocalMouse()
    var button = _td.pieceTray.activeTool
    var tx = localMouse[0] - (localMouse[0] % _tw)
    var ty = localMouse[1] - (localMouse[1] % _th)

    if (button != null) {
      if (button.category == "tower") {
        // if it's a valid placement, place the tower
        if (_td.pieceTray.canAfford() && !isNotValidPiecePlacement(tx / _tw, ty / _th, 2, 2) && Trap.buttonPressed(Button.Click, 0, -1)) {
          setTower(tx / _tw, ty / _th, button.variation)
          _td.pieceTray.spendCurrent()
        }
      } else if (button.category == "piece") {
        tx = tx - _tw
        ty = ty - _th

        // rotate piece
        if (Trap.buttonPressed(Button.Rotate, 0, -1)) {
          Debug.printLn("rotate")
          _td.pieceTray.rotateActivePiece()
        // if there's a click, attempt to place the wall
        } else if (_td.pieceTray.canAfford() && Trap.buttonPressed(Button.Click, 0, -1)) {
          var piece = _td.pieceTray.queuedPieces[button.variation]
          var success = setWallPiece(tx/_tw, ty/_th, _td.pieceTray.activePiece)
          // call into the piece tray to deduct currency, generate new piece, etc
          if (success) {
            _td.pieceTray.spendCurrent()
          }
        }
      } else if (button.category == "grass") {
        // if it's a valid placement, place the tower
        if (_td.pieceTray.canAfford() && !isNotValidPiecePlacement(tx / _tw, ty / _th, 1, 1) && Trap.buttonPressed(Button.Click, 0, -1)) {
          setGrass(tx / _tw, ty / _th)
          _td.pieceTray.spendCurrent()
        }
      }
    }

    generatePaths()

    var creeps = _entities.where{|e| e.type == "goat"}

    for (tower in _towers) {
      tower.update(dt, creeps)
    }

    for (entity in _entities) {
      entity.update(dt)
    }
    _entities = _entities.where {|c| !c.dead }.toList

    // clicking on the grid to place pieces is handled in draw()
  }

  draw() {
    Draw.translate(_x * _tw, _y * _th)

    // draw all the tiles on the map but ignore any tiles >= 200 since
    // those are reserved for blocking but non visible
    for (y in 0..._h) {
      for (x in 0..._w) {
        var tid = _tiles[y*_w+x]
        if (tid > 0 && tid < 200) {
          Draw.sprite(_td.spr, tid, x*_tw, y*_th)
        }
      }
    }

    for (tower in _towers) {
      tower.draw()
    }

    for (entity in _entities) {
      entity.draw()
    }

    // debug show how far each step is until the goal
    if (_showPathsCVar.bool()) {
      Draw.setTextStyle(_font, 6, 1.0, Align.Center+Align.Top)
      for (x in 0..._w) {
        for (y in 0..._h) {
          // checkerboard pattern
          var alpha = (y+x) % 2 == 0 ? 96 : 64
          var col = isBlocked(x, y) ? [255, 127, 127, alpha] : [64, 64, 64, alpha]
          Draw.setColor(col)
          Draw.rect(x*_tw, y*_th, _tw, _th, Fill.Solid)

          var dist = _paths[y * _w + x]
          if (dist != null) {
            var a = 127 - (dist * 4)
            Draw.setColor(255, 255, 255, 40)
            Draw.text(x * _tw, y * _th, 8, "%(dist)")
          }
        }
      }
    }

    // if something is selected, draw the piece shadow
    // snap it to the nearest 8px boundary
    var localMouse = getLocalMouse()
    if (!_td.paused && Math.pointInRect(localMouse[0], localMouse[1], 0, 0, _w*_tw, _h*_th) && _td.pieceTray.activeTool != null) {
      // tx and ty is misleadingly still pixels, just snapped to 8
      var tx = localMouse[0] - (localMouse[0] % _tw)
      var ty = localMouse[1] - (localMouse[1] % _th)

      var button = _td.pieceTray.activeTool

      // treat towers and pieces differently
      if (button.category == "tower") {
        _td.pieceTray.drawTool(tx, ty, button.id, true)
      } else if (button.category == "piece") {
        // shift over by one so you are pointing at the middle of a 3x3 tile
        tx = tx - _tw
        ty = ty - _th
        _td.pieceTray.drawPiece(tx, ty, 1.0, _td.pieceTray.activePiece)
      } else if (button.category == "grass") {
        _td.pieceTray.drawTool(tx, ty, button.id)
      }

    }

    Draw.translate(0 - _x * _tw, 0 - _y * _th)
  }

  setGoal(x, y) {
    Debug.printLn("setting goal to %(x),%(y)")
    _entities = _entities.where {|e| e.type != "coin" }.toList
    _entities.add(Coin.new(_td, x, y))
    _goalX = x
    _goalY = y
    generatePaths()
  }

  getDistance(x, y) {
    return _paths[y * _w + x]
  }

  generatePaths() {
    var frontier = [[_goalX, _goalY]]
    var dist = {}
    dist[_goalY * _w + _goalX] = 0

    while (frontier.count > 0) {
      var current = frontier.removeAt(0)
      var curCoord = current[1] * _w + current[0]

      if (current[0] > 0) {
        expandFrontier(frontier, dist, curCoord, current[0] - 1, current[1])
      }

      if (current[0] < _w) {
        expandFrontier(frontier, dist, curCoord, current[0] + 1, current[1])
      }

      if (current[1] > 0) {
        expandFrontier(frontier, dist, curCoord, current[0], current[1] - 1)
      }

      if (current[1] < _h) {
        expandFrontier(frontier, dist, curCoord, current[0], current[1] + 1)
      }
    }

    _paths = dist
  }

  expandFrontier(frontier, dist, curCoord, nextX, nextY) {
    var next = nextY * _w + nextX
    if (dist[next] == null && !isBlocked(nextX, nextY, true)) {
      frontier.insert(-1, [nextX, nextY])
      dist[next] = dist[curCoord] + 1
    }
  }

  isNotValidPiecePlacement(x, y, w, h) {
    if (x < 2) {
      return true
    }

    for (xOffset in 0..(w-1)) {
      for (yOffset in 0..(h-1)) {
        if (isBlocked(x + xOffset, y + yOffset, false)) {
          return true
        }
      }
    }
    return false
  }

  isBlocked(x, y) { isBlocked(x,y,false) }

  isBlocked(x, y, ignoreGrass) {
    var oob = x < 0 || x >= _w || y < 0 || y >= _h

    if (oob) {
      return true
    }

    var tid = _tiles[y * _w + x]
    var hasTile = ignoreGrass ? (tid > 0 && tid != 22) : tid > 0
    // WARNING: arrows and such are entities, but are not usually on the tile boundary
    var hasEntity = _entities.any {|ent| ent.x == x && ent.y == y }
    return hasTile || hasEntity
  }
}
