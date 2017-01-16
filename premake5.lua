solution "game"
  configurations { "Debug", "Release" }
  location "build"
  platforms {"x86", "x64"}

  configuration { "macosx" }
    buildoptions {"-Wno-unused-parameter"}

  configuration { "windows" }
  	toolset "v141"

  configuration "Debug"
    defines { "DEBUG" }
    flags { "Symbols", "ExtraWarnings" }

  configuration "Release"
    defines { "NDEBUG" }
    flags { "Optimize", "ExtraWarnings" }

  project "game"
    kind "ConsoleApp"
    language "C++"
    files { "src/**.c", "src/**.cpp", "src/**.h", "src/**.hh" }
    sysincludedirs { "include", "nanovg", "tmx", "imgui", "physfs", "entityx", "glew" }
    debugdir "."
    targetdir "bin/%{cfg.buildcfg}"
    links { "nanovg", "tmx", "imgui", "physfs", "glew", "entityx" }

    configuration { "windows" }
      libdirs { "lib/Win32" }
      links { "SDL2", "SDL2main", "opengl32" }
      defines { "_CRT_SECURE_NO_WARNINGS" }
      postbuildcommands {
        '{COPY} "%{wks.location}../lib/win32/SDL2.dll" "%{cfg.targetdir}"'
      }

    configuration { "macosx" }
      links { "OpenGL.framework", "SDL2.framework", "CoreFoundation.framework", "IOKit.framework", "CoreServices.framework", "Cocoa.framework" }
      buildoptions {"-std=c++14", "-stdlib=libc++"}
      linkoptions {"-stdlib=libc++", "-F /Library/Frameworks"}

  project "nanovg"
    language "C"
    kind "StaticLib"
    includedirs { "nanovg" }
    files { "nanovg/**.c", "nanovg/**.h" }
    targetdir "build"
    defines { "_CRT_SECURE_NO_WARNINGS" }

  project "tmx"
    language "C++"
    kind "StaticLib"
    sysincludedirs { "include" }
    files { "tmx/**.c", "tmx/**.h", "tmx/**.cpp" }
    targetdir "build"
    defines { "_CRT_SECURE_NO_WARNINGS" }
    buildoptions {"-std=c++14", "-stdlib=libc++"}

  project "imgui"
    language "C++"
    kind "StaticLib"
    files { "imgui/**.cpp", "imgui/**.h" }
    targetdir "build"

  project "physfs"
    language "C"
    kind "StaticLib"
    defines { "_CRT_SECURE_NO_WARNINGS", "PHYSFS_SUPPORTS_ZIP", "PHYSFS_SUPPORTS_QPAK", "PHYSFS_INTERNAL_ZLIB"}
    files { "physfs/**.c", "physfs/**.h" }
    targetdir "build"

  project "glew"
    language "C++"
    kind "StaticLib"
    defines { "GLEW_STATIC" }
    includedirs { "glew" }
    files { "glew/**.c", "glew/**.h" }
    targetdir "build"

  project "entityx"
    language "C++"
    kind "StaticLib"
    buildoptions {"-std=c++14", "-stdlib=libc++"}
    includedirs { "entityx" }
    files { "entityx/**.cc", "entityx/**.h" }
    targetdir "build"