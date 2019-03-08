#include <SDL/SDL.h>

#include "gamedll.h"
#include "../game/public.h"
#include "console/console.h"
#include "main.h"
#include "files.h"
#include "input.h"
#include "rendercommands.h"
#include "assetloader.h"

extern ClientInfo inf;

static gameImportFuncs_t GAMEtraps = {
	Con_Execute,
	Con_Printf,
	Com_Error,
	SetWindowTitle,
	Con_GetVarDefault,
	Con_GetVar,
	Con_SetVar,
	Con_GetArgsCount,
	Con_GetArg,
	Con_GetArgs,
	FS_ReadFile,
	FS_Exists,
	FS_List,
	FS_FreeList,
	IN_KeyDown,
	IN_KeyUp,
	IN_KeyPressed,
	IN_MousePosition,
	SubmitRenderCommands,
	Asset_Create,
	Asset_Find,
	Asset_Load,
	Asset_LoadAll,
	Asset_ClearAll,
	BMPFNT_Set,
	Asset_TextWidth,
	Sprite_Set,
	Canvas_Set,
	Shader_Set,
	Get_Img,
	Get_TileMap,
	Snd_Play,
	Snd_Stop,
	Snd_PauseResume,
};

#ifdef __EMSCRIPTEN__
extern "C" void dllEntry(void ** exports, void * imports);
void Sys_LoadDll(const char * module, void ** exports) {
	dllEntry(exports, &GAMEtraps);
}
#else
void Sys_LoadDll(const char * module, void ** exports) {
	void *gameDLL;

	gameDLL = SDL_LoadObject(va("%s/%s/%s", fs_basepath->string, fs_game->string, module));

	if (gameDLL == nullptr) {
		gameDLL = SDL_LoadObject(va("%s/%s/%s", fs_basepath->string, fs_basegame->string, module));
	}

	if (gameDLL == nullptr) {
		gameDLL = SDL_LoadObject(va("%s/%s", fs_basepath->string, module));
	}

	if (gameDLL == nullptr) {
		gameDLL = SDL_LoadObject(module);
	}

	void(*gameDllEntry)(void ** exports, const void * imports) = (void(*)(void **, const void *)) SDL_LoadFunction(gameDLL, "dllEntry");

	if (gameDllEntry == nullptr) {
		Com_Error(ERR_FATAL, "Couldn't find dllEntry in %s", module);
		return;
	}

	gameDllEntry(exports, &GAMEtraps);

}
#endif
