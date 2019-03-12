--
newoption {
  trigger = "emscripten",
  description = "use with gmake2 to build emscripten ready makefile",
  default = false
}

-- for use by the virtual filesystem, and emscripten packaging.
newoption {
  trigger = "default-game",
  description = "default game data dir, sets DEFAULT_GAME for engine and emscripten packaging",
  default = "plat"
}

solution "Slate2D"
  configurations { "Debug", "Release" }
  location "build"
  warnings "Extra"
  systemversion "latest"

  filter { "system:windows" }
    platforms { "x86", "x64" }

  filter { "system:macosx" }
    defines { "MACOS" }
    platforms { "x64" }
    buildoptions {"-Wno-unused-parameter"}

  filter { "system:linux" }
    platforms { "x64" }
    toolset "clang"
  
  filter { "configurations:Debug" }
    defines { "DEBUG" }
    symbols "On"
    optimize "Off"

  filter { "configurations:Release" }
    defines { "NDEBUG" }
    symbols "Off"
    optimize "Full"

  project "engine"
    kind "ConsoleApp"
    language "C++"
    files { "src/**.c", "src/**.cpp", "src/**.h", "src/**.hh" }
    -- only used in emscripten build
    removefiles { "src/imgui_impl_sdl_es2.cpp" }
    sysincludedirs { "src/external", "libs/sdl", "libs/tmx", "libs/imgui", "libs/physfs", "libs/glew", "libs/soloud/include", "libs/crunch" }
    -- physfs uses the exe path by default, but the game data files are in the top folder
    debugargs { "+set", "fs_basepath", path.getabsolute(".")}
    targetdir "build/bin/%{cfg.buildcfg}"
    links { "tmx", "imgui", "physfs", "glew", "soloud", "crunch" }
    cppdialect "C++14"
    -- define so engine and emscripten packaging are always in sync on the same base game folder 
    defines { "DEFAULT_GAME=\"" .. _OPTIONS["default-game"] .. "\""}

    -- rlgl and raymath have some warnings, suppress them here
    filter { "files:src/glinit.c"}
      disablewarnings { 4204, 4100, 4267 }

    -- compile all .c files in c mode so we don't get name mangling
    filter { "files:**.c"}
      language "C"

    -- hide the console window in release mode
    filter { "configurations:Release" }
      kind "WindowedApp"

    -- link SDL bins in the source tree on windows
    filter { "system:windows" }
      links { "SDL2", "SDL2main", "opengl32" }
      defines { "_CRT_SECURE_NO_WARNINGS" }

      filter { "platforms:x86", "system:windows" }
        libdirs { "libs/sdl/lib/Win32" }
        -- need to copy x86 sdl runtime to output
        postbuildcommands {
          '{COPY} "%{wks.location}../libs/sdl/lib/win32/SDL2.dll" "%{cfg.targetdir} ',
          '{COPY} "%{wks.location}../libs/openmpt/win32/*.dll" "%{cfg.targetdir}" '
        }

      filter { "platforms:x64", "system:windows" }
        libdirs { "libs/sdl/lib/x64" }
        -- need to copy x64 sdl runtime to output
        postbuildcommands {
          '{COPY} "%{wks.location}../libs/sdl/lib/x64/SDL2.dll" "%{cfg.targetdir}" ',
          '{COPY} "%{wks.location}../libs/openmpt/x64/*.dll" "%{cfg.targetdir}" '
        }

    -- use system installed SDL2 framework on mac
    filter { "system:macosx" }
      links { "OpenGL.framework", "SDL2.framework", "CoreFoundation.framework", "IOKit.framework", "CoreServices.framework", "Cocoa.framework" }
      linkoptions {"-stdlib=libc++", "-F /Library/Frameworks"}

    -- emscripten uses opengl es2, not gl3
    filter { "action:gmake2", "options:emscripten" }
      targetextension ".bc"
      files { "src/imgui_impl_sdl_es2.cpp" }
      removefiles { "src/imgui_impl_sdl_gl3.cpp" }
      links { "game" }
      -- build the html bundle, overlay the default game folder on top of base
      postbuildcommands { "mkdir html; emcc -O2 --preload-file ../base --preload-file ../" .. _OPTIONS["default-game"] .. " -s ALLOW_MEMORY_GROWTH=1 -s USE_SDL=2 %{cfg.targetdir}/engine.bc -o html/index.html --shell-file ../src/emshell.html" }
      
    filter { "system:linux" }
      links { "SDL2", "dl", "pthread", "GL" }

  -- game is a dll, except under emscripten
  project "game"
    kind "SharedLib"
    language "C++"
    files { "game/**.c", "game/**.cpp", "game/**.h", "game/**.hh" }
    sysincludedirs { "libs/tmx", "libs/imgui" }
    targetdir "build/bin/%{cfg.buildcfg}"
    cppdialect "C++14"
    links { "tmx", "imgui" }

    filter { "system:windows" }
      defines { "_CRT_SECURE_NO_WARNINGS" }

    -- emscripten doesn't really support dynamic dlls. the dll is setup to work
    -- as a static lib, just need to disable NaN tagging within wren due to an
    -- incompat there
    filter { "action:gmake2", "options:emscripten" }
      kind "StaticLib"
      targetdir "build/%{cfg.buildcfg}"
      defines "WREN_NAN_TAGGING=0"
      disablewarnings { "unknown-pragmas" }

    -- disable warnings for wren code since it's external
    filter { "files:game/wren/* or files:game/wreninspector.cpp" }
      disablewarnings { 4100, 4200, 4996, 4244, 4204, 4702, 4709 }
     
  group "libraries"

    project "tmx"
      language "C++"
      kind "StaticLib"
      files { "libs/tmx/**.c", "libs/tmx/**.h", "libs/tmx/**.cpp" }
      targetdir "build/%{cfg.buildcfg}"
      cppdialect "C++14"
      warnings "Off"

    project "imgui"
      language "C++"
      kind "StaticLib"
      files { "libs/imgui/**.cpp", "libs/imgui/**.h" }
      targetdir "build/%{cfg.buildcfg}"
      warnings "Off"
      
      filter { "system:linux" }
        pic "On"

    project "physfs"
      language "C"
      kind "StaticLib"
      defines { "PHYSFS_SUPPORTS_ZIP", "PHYSFS_SUPPORTS_7Z" }
      files { "libs/physfs/**.c", "libs/physfs/**.h" }
      targetdir "build/%{cfg.buildcfg}"
      warnings "Off"

      filter { "system:macosx" }
        undefines { "DEBUG" } -- fixes a weird issue on mac

    project "glew"
      language "C++"
      kind "StaticLib"
      defines { "GLEW_STATIC" }
      includedirs { "libs/glew" }
      files { "libs/glew/**.c", "libs/glew/**.h" }
      targetdir "build/%{cfg.buildcfg}"
      warnings "Off"

    project "soloud"
      language "C++"
      kind "StaticLib"
      targetdir "build/%{cfg.buildcfg}"
      targetname "soloud_static"
      warnings "Off"
      sysincludedirs { "libs/sdl" }
      defines { "MODPLUG_STATIC", "WITH_OPENMPT", "WITH_SDL2_STATIC" }
      files {
        "libs/soloud/src/audiosource/**.c*",
        "libs/soloud/src/filter/**.c*",
        "libs/soloud/src/core/**.c*",
        "libs/soloud/src/backend/sdl2_static/**.c*"
	    }
      includedirs {
        "libs/soloud/src/**",
        "libs/soloud/include",
        "libs/sdl/SDL" 
      }
      
      filter { "system:windows" }
        libdirs { "libs/sdl/lib/Win32" }
        links { "SDL2" }

      filter { "system:macosx" }
        links { "SDL2.framework" }
        linkoptions {"-F /Library/Frameworks"}

    project "crunch"
      language "C++"
      kind "StaticLib"
      includedirs { "libs/crunch", "src/" }
      sysincludedirs { "libs/physfs", "libs/imgui", "libs/sdl" }
      files { "libs/crunch/**.cpp", "libs/crunch/**.h", "libs/crunch/**.hpp" }
      targetdir "build/%{cfg.buildcfg}"
      warnings "Off"
