import "meta" for Meta
import "engine" for Trap, Draw, Asset, CVar

import "soundcontroller" for SoundController
import "timer" for Timer
import "debug" for Debug
import "title" for Title
import "game" for Game
import "cutscene" for Cutscene
import "gameover" for GameOver
import "levelending" for LevelEnding
import "ending" for Ending
import "help" for Help

class Main {
  static scene { __scene }

  static init(mapName) {
    __accumTime = 0
    __inspector = CVar.get("debug.wrenInspector", 0)

    __scenes = {
      "title": Title,
      "game": Game,
      "cutscene": Cutscene,
      "gameover": GameOver,
      "levelending": LevelEnding,
      "ending": Ending,
      "help": Help,
    }

    __defaultScene = "title"

    Trap.setWindowTitle("Hot Air")

    Trap.registerButtons(["up", "down", "left", "right", "start", "flap"])

    Timer.init()
    Debug.init()
    SoundController.init()

    if (mapName == null) {
      loadScene(__defaultScene, null)
      //loadScene("game", 2)
    }
  }

  static update(dt) {
    if (__scene && __scene.nextScene != null) {
      Trap.printLn("got scene transfer: %(__scene.nextScene)")
      if (__scene.nextScene is String) {
        loadScene(__scene.nextScene, null)
      } else {
        var params = __scene.nextScene.count > 1 ? __scene.nextScene[1] : null
        loadScene(__scene.nextScene[0], params)
      }
    }

    __accumTime = __accumTime + dt
    if (__accumTime >= 1/60) {
      __accumTime = __accumTime - 1/60
    } else {
      return false
    }

    Debug.persist(true)
    Debug.clearPersist()

    if (__scene != null) {
      if (__scene.update(1) != false) {
        Timer.tick(1)
      }
    } else {
      Timer.tick(1)
    }
  }

  static draw(w, h) {
    Debug.persist(false)
    Draw.clear(0, 0, 0, 255)
    if (__scene != null) {
      __scene.draw(w, h)
    }
    Debug.draw()
    Draw.submit()

    if (__inspector.bool()) {
      Trap.inspect(__scene)
    }
  }

  static console(line) {
    var fiber
    var isExpression
    if (line.startsWith("eval ")) {
      line = line["eval ".count..-1]
      fiber = Meta.compile(line)
    } else {
      isExpression = true
      fiber = Meta.compileExpression(line)
    }

    if (fiber == null) return
    var result = fiber.try()
    if (fiber.error != null) {
      Trap.printLn("Runtime error: %(fiber.error)")
      return
    }

    if (isExpression) {
      Trap.printLn(result)
    }
  }

  static shutdown() {
    if (__scene == null) {
      return
    }

    __scene.shutdown()
    __scene = null

    Asset.clearAll()
  }

  static loadScene(scene, params) {
    Timer.clear()
    shutdown()

    var next = scene == null || __scenes[scene] == null ? __defaultScene : scene
    __scene = __scenes[next].new(params)

    System.gc()
  }
}