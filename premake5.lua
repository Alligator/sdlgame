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
  symbols "On"
  systemversion "latest"
  targetdir "build/out/%{cfg.architecture}_%{cfg.buildcfg}"
  objdir "build/out/obj"
  startproject "wrengame"

  filter { "system:windows" }
    platforms { "x86", "x64" }

  filter { "system:macosx" }
    defines { "MACOS", "GL_SILENCE_DEPRECATION" }
    platforms { "x64" }

  filter { "system:linux" }
    platforms { "x64" }
    toolset "clang"
  
  filter { "configurations:Debug" }
    defines { "DEBUG" }
    optimize "Off"

  filter { "configurations:Release" }
    defines { "RELEASE" }
    optimize "Full"

  project "libslate2d"
    kind "SharedLib"
    targetname "slate2d"
    language "C++"
    files { "src/**.c", "src/**.cpp", "src/**.h", "src/**.hh" }
    -- only used in emscripten build
    removefiles { "src/imgui_impl_sdl_es2.cpp" }
    sysincludedirs { "src/external", "libs/sdl", "libs/tmx", "libs/imgui", "libs/physfs", "libs/glew", "libs/soloud/include", "libs/crunch" }
    -- physfs uses the exe path by default, but the game data files are in the top folder
    targetdir "build/bin/%{cfg.architecture}_%{cfg.buildcfg}"
    links { "tmx", "imgui", "physfs", "glew", "soloud", "crunch" }
    cppdialect "C++14"
    -- define so engine and emscripten packaging are always in sync on the same base game folder 
    defines { "DEFAULT_GAME=\"" .. _OPTIONS["default-game"] .. "\"", "COMPILE_DLL"}

    -- rlgl and raymath have some warnings, suppress them here
    filter { "files:src/glinit.c"}
      disablewarnings { 4204, 4100, 4267 }

    -- disable warnings for sds
    filter { "files:src/external/sds.c"}
      warnings "Off"

    -- compile all .c files in c mode so we don't get name mangling
    filter { "files:**.c"}
      language "C"

    -- link SDL bins in the source tree on windows
    filter { "system:windows" }
      links { "SDL2", "opengl32" }
      defines { "_CRT_SECURE_NO_WARNINGS" }

    filter { "platforms:x86", "system:windows" }
      libdirs { "libs/sdl/lib/Win32" }
      -- need to copy x86 sdl runtime to output
      postbuildcommands {
        '{COPY} "%{wks.location}../libs/sdl/lib/Win32/SDL2.dll" "%{cfg.targetdir}" ',
        '{COPY} "%{wks.location}../libs/openmpt/Win32/*.dll" "%{cfg.targetdir}" '
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
      -- build the html bundle, overlay the default game folder on top of base
      postbuildcommands { "mkdir html; emcc -O2 --preload-file ../base --preload-file ../" .. _OPTIONS["default-game"] .. " -s ALLOW_MEMORY_GROWTH=1 -s USE_SDL=2 %{cfg.targetdir}/engine.bc -o html/index.html --shell-file ../src/emshell.html" }
      
    filter { "system:linux" }
      links { "SDL2", "dl", "pthread", "GL" }

  project "wrengame"
    kind "ConsoleApp"
    language "C++"
    targetname "slate2d"
    files { "game/**.c", "game/**.cpp", "game/**.h", "game/**.hh" }
    sysincludedirs { "libs/tmx", "libs/imgui" }
    targetdir "build/bin/%{cfg.architecture}_%{cfg.buildcfg}"
    cppdialect "C++14"
    debugargs { "+set", "fs.basepath", path.getabsolute(".")}
    links { "tmx", "imgui", "sdl2main", "libslate2d" }

    filter { "platforms:x86", "system:windows" }
      libdirs { "libs/sdl/lib/Win32" }

    filter { "platforms:x64", "system:windows" }
      libdirs { "libs/sdl/lib/x64" }

    filter { "system:windows" }
      defines { "_CRT_SECURE_NO_WARNINGS" }

    -- NaN tagging doesn't work in wren
    filter { "action:gmake2", "options:emscripten" }
      defines "WREN_NAN_TAGGING=0"
      disablewarnings { "unknown-pragmas" }

    -- disable warnings for wren code since it's external
    filter { "files:game/wren/* or files:game/wreninspector.cpp" }
      disablewarnings { 4100, 4200, 4996, 4244, 4204, 4702, 4709 }

    -- disable warnings for sds
    filter { "files:../src/external/sds.c"}
      warnings "Off"
     
  group "libraries"

    project "tmx"
      language "C++"
      kind "StaticLib"
      files { "libs/tmx/**.c", "libs/tmx/**.h", "libs/tmx/**.cpp" }
      cppdialect "C++14"
      warnings "Off"

    project "imgui"
      language "C++"
      kind "StaticLib"
      files { "libs/imgui/**.cpp", "libs/imgui/**.h" }
      warnings "Off"
      
      filter { "system:linux" }
        pic "On"

    project "physfs"
      language "C"
      kind "StaticLib"
      defines { "PHYSFS_SUPPORTS_ZIP", "PHYSFS_SUPPORTS_7Z", "PHYSFS_DECL=" }
      files { "libs/physfs/**.c", "libs/physfs/**.h", "libs/physfs/**.m" }
      warnings "Off"

      filter { "system:macosx" }
        undefines { "DEBUG" } -- fixes a weird issue on mac

    project "glew"
      language "C++"
      kind "StaticLib"
      defines { "GLEW_STATIC" }
      includedirs { "libs/glew" }
      sysincludedirs { "libs/glew" }
      files { "libs/glew/**.c", "libs/glew/**.h" }
      warnings "Off"

    project "soloud"
      language "C++"
      kind "StaticLib"
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

    project "crunch"
      language "C++"
      cppdialect "C++14"
      kind "StaticLib"
      includedirs { "libs/crunch", "src/" }
      sysincludedirs { "libs/physfs", "libs/imgui", "libs/sdl" }
      files { "libs/crunch/**.cpp", "libs/crunch/**.h", "libs/crunch/**.hpp" }
      warnings "Off"
