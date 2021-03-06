class Dir {
  static Left { 1 }
  static Right { 2 }
  static Up { 4 }
  static Down { 8 }
}

class Dim {
  static H { 1 }
  static V { 2 }
}

// don't bother releasing since nothing ever needs for more than a single frame.
// just cycle through the 16
class CollisionPool {
  static init() {
    __pool = []
    __curr = 0
    __max = 16

    for (i in 1..__max) {
      __pool.add(Collision.new())
    }
  }

  static get() {
    var res = __pool[__curr]
    res.clear()
    __curr = (__curr + 1) % __max
    return res
  }
}

// storage class since we need to know distance to trigger to filter
// them out during movement
class CollisionInfo {
  delta { _delta }
  entity { _entity }
  construct new(delta, entity) {
    _delta = delta
    _entity = entity
  }
}

// list wrapper since we want to support colliding with triggers and
// regular entities every frame.
class CollisionList {
  list { _list }

  construct new() {
    _list = []
  }

  add(delta, entity) {
    _list.add(CollisionInfo.new(delta, entity))
  }

  filter(delta) {
    if (_list.isEmpty) {
      return
    }

    for (i in _list.count-1..0) {
      if (delta.abs < _list[i].delta.abs) {
        _list.removeAt(i)
      }
    }
  }

  has(prop) {
    return _list.any { |info| info.entity.has(prop) }
  }
}

// storage class for collision. don't alloc these directly, use CollisionPool
class Collision {
  delta { _delta }
  t { _t }
  entity { _entity }
  entity=(e) { _entity = e }
  side { _side }
  triggers { _triggers }
  entities { _entities }

  construct new() {
  }

  clear() {
    _delta = 0
    _t = 0
    _entity = null
    _side = 0
    _triggers = CollisionList.new()
    _entities = CollisionList.new()
  }

  set(delta, entity, side, t) {
    _delta = delta
    _entity = entity
    _side = side
    _t = t

    _triggers.filter(delta)
    _entities.filter(delta)

    return this
  }
}

class TileCollider {
  construct new(getTile, tileWidth, tileHeight) {
    _tw = tileWidth
    _th = tileHeight
    _getTile = getTile
  }

  getTileRange(ts, x, w, d) {
    var gx = (x / ts).floor
    var right = x+w+d
    right = right == right.floor ? right - 1 : right
    var gx2 = d >= 0 ? (right / ts).floor : ((x+d) / ts).floor
    //Debug.text("gtr", "%(x) %(w) %(d) %(gx..gx2)")

    return gx..gx2
  }

  query(x, y, w, h, dim, d, resolveFn) {
    if (dim == Dim.H) {
      var origPos = x + d
      var xRange = getTileRange(_tw, x, w, d)
      var yRange = getTileRange(_th, y, h, 0)

      for (tx in xRange) {
        for (ty in yRange) {
          //Debug.rectb(tx*8, ty*8, 8, 8, 4)
          var tile = _getTile.call(tx, ty)
          if (tile > 0) {
            var dir = d < 0 ? Dir.Left : Dir.Right
            if (resolveFn.call(dir, tile, tx, ty, d, 0) == true) {
              //Debug.rectb(tx*8, ty*8, 8, 8, 8)
              var check = origPos..(tx + (d >= 0 ? 0 : 1)) *_tw - (d >= 0 ? w : 0)
              return (d < 0 ? check.max : check.min) - x
            }
          }
        }
      }

      return d
    } else {
      var origPos = y + d
      var xRange = getTileRange(_tw, x, w, 0)
      var yRange = getTileRange(_th, y, h, d)

      for (ty in yRange) {
        for (tx in xRange) {
          //Debug.rectb(tx*8, ty*8, 8, 8, 4)
          var tile = _getTile.call(tx, ty)
          if (tile > 0) {
            var dir = d < 0 ? Dir.Up : Dir.Down
            if (resolveFn.call(dir, tile, tx, ty, 0, d) == true) {
              //Debug.rectb(tx*8, ty*8, 8, 8, 8)
              var check = origPos..(ty + (d >= 0 ? 0 : 1)) *_th - (d >= 0 ? h : 0)
              return (d < 0 ? check.max : check.min) - y
            }
          }
        }
      }

      return d
    }
  }
}
