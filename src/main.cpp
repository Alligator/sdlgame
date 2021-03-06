#include <iostream>
#include <cmath>
#include <chrono>
#include <thread>
#include <stdint.h>

#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#endif

#ifdef __EMSCRIPTEN__
#include "GLES2/gl2.h"
#include "GLES2/gl2ext.h"
#define NO_SDL_GLEXT
#else
#define GLEW_STATIC
#include <GL/glew.h>
#endif

#include <SDL/SDL.h>
#include <SDL/SDL_opengl.h>

extern "C" {
#include "rlgl.h"
	extern bool initGL(int width, int height);
}

#include <imgui.h>
#include "imgui_impl_sdl.h"

#include "files.h"
#include "input.h"
#include "keys.h"
#include "cvar_main.h"

#include "imgui_console.h"

#include "shared.h"

#include <soloud.h>
#include <soloud_thread.h>

#include "filewatcher.h"
#include "crunch_frontend.h"
#include "assetloader.h"

extern "C" {
#include "console.h"
}

#include "external/fontstash.h"
#include "main.h"
#include "rendercommands.h"

conState_t console;

SoLoud::Soloud soloud;
ClientInfo inf;
int64_t last_update_musec = 0, frame_musec = 0, com_frameTime = 0;
//float frame_accum;
bool frameAdvance = false;
bool errorVisible = false;
long long now = 0;
static renderCommandList_t cmdList;
SDL_Window *window;
SDL_GLContext context;
bool shouldQuit = false;
bool frameStarted = false;
void(*hostErrHandler)(int level, const char *msg);

const char * __cdecl tempstr(const char *format, ...) {
	va_list		argptr;
	static char		string[2][32000];	// in case va is called by nested functions
	static int		index = 0;
	char	*buf;

	buf = string[index & 1];
	index++;

	va_start(argptr, format);
	vsprintf(buf, format, argptr);
	va_end(argptr);

	return buf;
}

void SetWindowTitle(const char *title) {
	SDL_SetWindowTitle(window, title);
}

void Cmd_FrameAdvance_f(void) {
	if (!eng_pause->integer) {
		Con_SetVar("engine.pause", "1");
	}
	else {
		frameAdvance = true;
	}
}
void Cmd_Vid_Restart_f(void) {
	inf.width = vid_width->integer;
	inf.height = vid_height->integer;

	SDL_SetWindowSize(window, inf.width, inf.height);
	SDL_GL_SetSwapInterval(vid_swapinterval->integer);
	SDL_SetWindowFullscreen(window, vid_fullscreen->integer == 2 ? SDL_WINDOW_FULLSCREEN : vid_fullscreen->integer == 1 ? SDL_WINDOW_FULLSCREEN_DESKTOP : 0);
}

void Cmd_Exec_f() {
	if (Con_GetArgsCount() != 2) {
		Con_Printf("exec <filename> - runs the contents of filename as a console script\n");
		return;
	}

	sds name = sdsnew(Con_GetArg(1));

	if (strcmp(&name[sdslen(name) - 4], ".cfg") == 0) {

	}
	if (!FS_Exists(name)) {
		Con_Printf("couldn't exec file %s\n", name);
		return;
	}

	void *buffer;
	auto sz = FS_ReadFile(name, &buffer);
	const char *str = (const char *)buffer;

	Con_Execute(str);

	free(buffer);
	sdsfree(name);
}

void Cmd_Clear_f() {
	IMConsole()->ClearLog();
}

void ConH_Print(const char *line) {
	IMConsole()->AddLog("%s", line);
	printf("%s", line);
}

void ConH_Error(int level, const char *message) {
	Con_Print(message);

#if defined(_WIN32) && defined(DEBUG)
	if (level == ERR_FATAL) {
		__debugbreak();
	}
#else
	if (level == ERR_FATAL) {
		SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "Fatal Error", message, NULL);
	}
#endif

	if (level == ERR_FATAL) {
		exit(1);
	}
	else {
		Con_SetVar("engine.errorMessage", message);
		errorVisible = true;
		hostErrHandler(level, message);
	}
}

static void Cmd_Quit_f(void) {
	shouldQuit = true;
}

auto start = std::chrono::steady_clock::now();

static inline long long measure_now() {
	return std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::steady_clock::now() - start).count();
}

SLT_API double SLT_StartFrame() {
	if (shouldQuit) {
		return -1;
	}

	if (frameStarted) {
		return 0;
	}

	now = measure_now();
	frame_musec = now - com_frameTime;
	com_frameTime = now;

	SDL_Event ev;
	ImGuiIO &io = ImGui::GetIO();
	while (SDL_PollEvent(&ev)) {
		ImGui_ImplSdl_ProcessEvent(&ev);

		switch (ev.type) {
		case SDL_QUIT:
			return -1;
		case SDL_KEYDOWN:
			if (ev.key.keysym.sym == SDLK_BACKQUOTE) {
				IMConsole()->consoleActive = !IMConsole()->consoleActive;
				ImGui::SetWindowFocus(nullptr);
				break;
			}
		default:
			ProcessInputEvent(ev);
		}
	}

	frameStarted = true;

	memset(&cmdList, 0, sizeof(cmdList));

	if (snd_volume->modified) {
		soloud.setGlobalVolume(snd_volume->value);
		snd_volume->modified = false;
	}

	FileWatcher_Tick();
	
	ImGui_ImplSdl_NewFrame(window);

	if (errorVisible && eng_errorMessage->string[0] == '\0') {
		errorVisible = 0;
	}
	else if (errorVisible) {
		ImGui::SetNextWindowPosCenter();
		ImGui::Begin("Error", NULL, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_AlwaysAutoResize);
		ImGui::Text("%s", eng_errorMessage->string);
		ImGui::Text("%s", eng_lastErrorStack->string);
		ImGui::NewLine();
		if (ImGui::Button("Close")) {
			errorVisible = false;
			Con_SetVar("engine.errorMessage", nullptr);
			Con_SetVar("engine.lastErrorStack", nullptr);
		}
		ImGui::End();
	}

	rlMatrixMode(RL_PROJECTION);                            // Enable internal projection matrix
	rlLoadIdentity();                                       // Reset internal projection matrix
	rlOrtho(0.0, inf.width, inf.height, 0.0, 0.0, 1.0); // Recalculate internal projection matrix
	rlMatrixMode(RL_MODELVIEW);                             // Enable internal modelview matrix
	rlLoadIdentity();                                       // Reset internal modelview matrix

	return !eng_pause->integer || frameAdvance ? frame_musec / 1E6 : 0;
}

SLT_API void SLT_EndFrame() {
	if (!frameStarted) {
		return;
	}

	frameStarted = false;

	if (!eng_pause->integer || frameAdvance) {
		frameAdvance = false;
	}

	IMConsole()->Draw(&inf);
	Asset_DrawInspector();

	ImGui::Render();
	ImGui_ImplSdl_RenderDrawData(ImGui::GetDrawData());

	if (debug_fontAtlas->integer) {
		rlLoadIdentity();
		if (ctx != nullptr) fonsDrawDebug(ctx, 0, 32);
		rlglDraw();
	}

	SDL_GL_SwapWindow(window);

	// OSes seem to not be able to sleep for shorter than a millisecond. so let's sleep until
	// we're close-ish and then burn loop the rest. we get a majority of the cpu/power gains
	// while still remaining pretty accurate on frametimes.
	if (vid_maxfps->integer > 0) {
		long long target = now + (long long)(1000.0f / vid_maxfps->integer * 1000);
		long long currentSleepTime = measure_now();
		while (currentSleepTime <= target) {
			long long amt = (target - currentSleepTime) - 2000;
			if (amt > 0) {
				std::this_thread::sleep_for(std::chrono::microseconds(amt));
			}
			currentSleepTime = measure_now();
		}
	}
}

SLT_API void SLT_Init(int argc, char* argv[]) {
	// initialize console. construct imgui console, setup handlers, and then initialize the actual console
	IMConsole();
	console.handlers.print = &ConH_Print;
	console.handlers.getKeyForString = &In_GetKeyNum;
	console.handlers.getStringForKey = &In_GetKeyName;
	console.handlers.error = &ConH_Error;

	Con_Init(&console);
	Con_AllocateKeys(MAX_KEYS);

	// setup console to pull cvars from command line
	Con_SetupCommandLine(argc, argv);

	// we don't have a filesystem yet so we don't want to run the whole command line
	// yet. pick out the convars that are important for FS initialization, and then later on
	// we'll run the rest.
	Con_SetVarFromStartup("fs.basepath");
	Con_SetVarFromStartup("fs.basegame");
	Con_SetVarFromStartup("fs.game");
	FS_Init(argv[0]);

	// add engine level commands here
	Con_AddCommand("exec", Cmd_Exec_f);
	Con_AddCommand("quit", Cmd_Quit_f);
	Con_AddCommand("vid_restart", Cmd_Vid_Restart_f);
	Con_AddCommand("frame_advance", Cmd_FrameAdvance_f);
	Con_AddCommand("clear", Cmd_Clear_f);

	RegisterMainCvars();
	FileWatcher_Init();
	Crunch_Init();

	if (!FS_Exists("default.cfg")) {
		Con_Error(ERR_FATAL, "Filesystem error, check fs_basepath is set correctly. (Could not find default.cfg)");
	}

	Con_Execute("exec default.cfg\n");
	if (FS_Exists("autoexec.cfg")) {
		Con_Execute("exec autoexec.cfg\n");
	}

	SDL_SetMainReady();

	if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_GAMECONTROLLER) < 0) {
		Con_Errorf(ERR_FATAL, "There was an error initing SDL2: %s", SDL_GetError());
	}

	atexit(SDL_Quit);
#ifdef __EMSCRIPTEN__
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
#else
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GLprofile::SDL_GL_CONTEXT_PROFILE_CORE);
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
#endif

	inf.width = vid_width->integer;
	inf.height = vid_height->integer;
	window = SDL_CreateWindow("Slate2D", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, inf.width, inf.height, SDL_WINDOW_OPENGL);

	if (window == NULL) {
		Con_Errorf(ERR_FATAL, "There was an error creating the window: %s", SDL_GetError());
	}

	SDL_SetWindowFullscreen(window, vid_fullscreen->integer == 2 ? SDL_WINDOW_FULLSCREEN : vid_fullscreen->integer == 1 ? SDL_WINDOW_FULLSCREEN_DESKTOP : 0);

	context = SDL_GL_CreateContext(window);

	if (!initGL(inf.width, inf.height)) {
		Con_Error(ERR_FATAL, "Could not init GL.");
	}

	SDL_GL_SetSwapInterval(vid_swapinterval->integer);

	if (context == NULL) {
		Con_Errorf(ERR_FATAL, "There was an error creating OpenGL context: %s", SDL_GetError());
	}

	const unsigned char* version = glGetString(GL_VERSION);
	if (version == NULL) {
		Con_Error(ERR_FATAL, "There was an error with OpenGL configuration.");
	}

	SoLoud::result result = soloud.init();
	if (result != 0) {
		Con_Errorf(ERR_FATAL, "Error initializing audio: %s", soloud.getErrorString(result));
	}

	SDL_GL_MakeCurrent(window, context);

	ImGui::CreateContext();
	ImGui_ImplSdl_Init(window);

	ImGui::StyleColorsDark();
	ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, 0.0);

	ImGuiIO& io = ImGui::GetIO();
#ifdef RELEASE
	io.IniFilename = NULL;
#endif

	// not working in emscripten for some reason? assert on ImGuiKey_Space not being mapped
#ifndef __EMSCRIPTEN__	
	io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
#endif

	// now that we've ran the user configs and initialized everything else, apply everything else on the
	// command line here. this will set the rest of the variables and run any commands specified.
	Con_ExecuteCommandLine();

	// FIXME: needs to do something
	//console.handlers.unhandledCommand = gexports->Console;
}

SLT_API void SLT_Shutdown() {
	Con_Shutdown();
	Asset_ClearAll();
	ImGui_ImplSdl_Shutdown();
	ImGui::DestroyContext();
	SDL_GL_DeleteContext(context);
}

SLT_API void SLT_Con_SetErrorHandler(void(*errHandler)(int level, const char *msg)) {
	hostErrHandler = errHandler;
}

SLT_API void SLT_SendConsoleCommand(const char* text) {
	Con_Execute(text);
}

SLT_API void SLT_Print(const char* fmt, ...) {
	va_list args;
	va_start(args, fmt);
	Con_PrintfV(fmt, args);
	va_end(args);
}

SLT_API void SLT_Error(int level, const char* error, ...) {
	va_list args;
	va_start(args, error);
	Con_RawErrorV(level, error, args);
	va_end(args);
}

SLT_API void SLT_SetWindowTitle(const char* title) {
	SetWindowTitle(title);
}

SLT_API conVar_t* SLT_Con_GetVarDefault(const char* var_name, const char* var_value, int flags) {
	return Con_GetVarDefault(var_name, var_value, flags);
}

SLT_API conVar_t* SLT_Con_GetVar(const char* name) {
	return Con_GetVar(name);
}

SLT_API conVar_t* SLT_Con_SetVar(const char* var_name, const char* value) {
	return Con_SetVar(var_name, value);
}

SLT_API int SLT_Con_GetArgCount(void) {
	return Con_GetArgsCount();
}

SLT_API const char* SLT_Con_GetArg(int arg) {
	return Con_GetArg(arg);
}

SLT_API const char* SLT_Con_GetArgs(int start) {
	return Con_GetArgs(start);
}

SLT_API void SLT_Con_AddCommand(const char *name, conCmd_t cmd) {
	Con_AddCommand(name, cmd);
}

SLT_API int SLT_FS_ReadFile(const char* path, void** buffer) {
	return FS_ReadFile(path, buffer);
}

SLT_API bool SLT_FS_Exists(const char* file) {
	return FS_Exists(file);
}

SLT_API char** SLT_FS_List(const char* path) {
	return FS_List(path);
}

SLT_API void SLT_FS_FreeList(void* listVar) {
	FS_FreeList(listVar);
}

SLT_API void SLT_In_AllocateButtons(const char** buttonNames, int buttonCount) {
	Con_AllocateButtons(buttonNames, buttonCount);
}

SLT_API buttonState_t* SLT_In_GetButton(int buttonNum) {
	return Con_GetButton(buttonNum);
}

SLT_API bool SLT_In_ButtonPressed(int buttonId, unsigned int delay, int repeat) {
	return In_ButtonPressed(buttonId, delay, repeat);
}

SLT_API MousePosition SLT_In_MousePosition() {
	return In_MousePosition();
}

SLT_API void SLT_SubmitRenderCommands(renderCommandList_t* list) {
	SubmitRenderCommands(list);
}

SLT_API AssetHandle SLT_Asset_Create(AssetType_t assetType, const char* name, const char* path, int flags) {
	return Asset_Create(assetType, name, path, flags);
}

SLT_API AssetHandle SLT_Asset_Find(const char* name) {
	return Asset_Find(name);
}

SLT_API void SLT_Asset_Load(AssetHandle assetHandle) {
	Asset_Load(assetHandle);
}

SLT_API void SLT_Asset_LoadAll() {
	Asset_LoadAll();
}

SLT_API void SLT_Asset_ClearAll() {
	Asset_ClearAll();
}

SLT_API void SLT_Asset_LoadINI(const char* path) {
	Asset_LoadINI(path);
}

SLT_API void SLT_Asset_BMPFNT_Set(AssetHandle assetHandle, const char* glyphs, int glyphWidth, int charSpacing, int spaceWidth, int lineHeight) {
	BMPFNT_Set(assetHandle, glyphs, glyphWidth, charSpacing, spaceWidth, lineHeight);
}

SLT_API int SLT_Asset_TextWidth(AssetHandle assetHandle, const char* string, float scale) {
	return Asset_TextWidth(assetHandle, string, scale);
}

SLT_API const char* SLT_Asset_BreakString(int width, const char* in) {
	return TTF_BreakString(width, in);
}

SLT_API void SLT_Asset_Sprite_Set(AssetHandle assetHandle, int width, int height, int marginX, int marginY) {
	Sprite_Set(assetHandle, width, height, marginX, marginY);
}

SLT_API void SLT_Asset_Canvas_Set(AssetHandle assetHandle, int width, int height) {
	Canvas_Set(assetHandle, width, height);
}

SLT_API void SLT_Asset_Shader_Set(AssetHandle id, bool isFile, const char* vs, const char* fs) {
	Shader_Set(id, isFile, vs, fs);
}

SLT_API Image* SLT_Get_Img(AssetHandle id) {
	return Get_Img(id);
}

SLT_API tmx_map* SLT_Get_TileMap(AssetHandle id) {
	return Get_TileMap(id);
}

SLT_API unsigned int SLT_Snd_Play(AssetHandle asset, float volume, float pan, bool loop) {
	return Snd_Play(asset, volume, pan, loop);
}

SLT_API void SLT_Snd_Stop(unsigned int handle) {
	Snd_Stop(handle);
}

SLT_API void SLT_Snd_PauseResume(unsigned int handle, bool pause) {
	Snd_PauseResume(handle, pause);
}

SLT_API const void* SLT_GetClientInfo() {
	return &inf;
}

SLT_API const void* SLT_GetImguiContext() {
	return ImGui::GetCurrentContext();
}

SLT_API void SLT_UpdateLastFrameTime() {
	last_update_musec = com_frameTime;
}

#define GET_COMMAND(type, id) type *cmd; cmd = (type *)R_GetCommandBuffer(sizeof(*cmd)); if (!cmd) { return; } cmd->commandId = id;

void* R_GetCommandBuffer(int bytes) {
	// always leave room for the end of list command
	if (cmdList.used + bytes + 4 > MAX_RENDER_COMMANDS) {
		if (bytes > MAX_RENDER_COMMANDS - 4) {
			SLT_Error(ERR_FATAL, "%s: bad size %i", __func__, bytes);
		}
		// if we run out of room, just start dropping commands
		return NULL;
	}

	cmdList.used += bytes;

	return cmdList.cmds + cmdList.used - bytes;
}

SLT_API void DC_Submit() {
	SLT_SubmitRenderCommands(&cmdList);
	memset(&cmdList, 0, sizeof(cmdList));
}

SLT_API void DC_Clear(uint8_t r, uint8_t g, uint8_t b, uint8_t a) {
	GET_COMMAND(clearCommand_t, RC_CLEAR);
	cmd->color[0] = r;
	cmd->color[1] = g;
	cmd->color[2] = b;
	cmd->color[3] = a;
}

SLT_API void DC_SetColor(uint8_t r, uint8_t g, uint8_t b, uint8_t a) {
	GET_COMMAND(setColorCommand_t, RC_SET_COLOR)
		cmd->color[0] = r;
	cmd->color[1] = g;
	cmd->color[2] = b;
	cmd->color[3] = a;
}

SLT_API void DC_ResetTransform() {
	GET_COMMAND(resetTransformCommand_t, RC_RESET_TRANSFORM)
}

SLT_API void DC_Scale(float x, float y) {
	GET_COMMAND(scaleCommand_t, RC_SCALE)
		cmd->x = x;
	cmd->y = y;
}

SLT_API void DC_Rotate(float angle) {
	GET_COMMAND(rotateCommand_t, RC_ROTATE);
	cmd->angle = angle;
}

SLT_API void DC_Translate(float x, float y) {
	GET_COMMAND(translateCommand_t, RC_TRANSLATE);
	cmd->x = x;
	cmd->y = y;
}

SLT_API void DC_SetScissor(int x, int y, int w, int h) {
	GET_COMMAND(setScissorCommand_t, RC_SET_SCISSOR)
		cmd->x = x;
	cmd->y = y;
	cmd->w = w;
	cmd->h = h;
}

SLT_API void DC_ResetScissor() {
	DC_SetScissor(0, 0, 0, 0);
}

SLT_API void DC_UseCanvas(unsigned int canvasId) {
	GET_COMMAND(useCanvasCommand_t, RC_USE_CANVAS)
		cmd->canvasId = canvasId;
}

SLT_API void DC_ResetCanvas() {
	GET_COMMAND(resetCanvasCommand_t, RC_RESET_CANVAS)
}

SLT_API void DC_UseShader(unsigned int shaderId) {
	GET_COMMAND(useShaderCommand_t, RC_USE_SHADER)
		cmd->shaderId = shaderId;
}

SLT_API void DC_ResetShader() {
	GET_COMMAND(resetShaderCommand_t, RC_RESET_SHADER)
}

SLT_API void DC_DrawRect(float x, float y, float w, float h, bool outline) {
	GET_COMMAND(drawRectCommand_t, RC_DRAW_RECT)
		cmd->outline = outline;
	cmd->x = x;
	cmd->y = y;
	cmd->w = w;
	cmd->h = h;
}

SLT_API void DC_SetTextStyle(unsigned int fntId, float size, float lineHeight, int align) {
	GET_COMMAND(setTextStyleCommand_t, RC_SET_TEXT_STYLE)

		cmd->fntId = fntId;
	cmd->size = size;
	cmd->lineHeight = lineHeight;
	cmd->align = align;
}

SLT_API void DC_DrawText(float x, float y, float w, const char* text, int len) {
	GET_COMMAND(drawTextCommand_t, RC_DRAW_TEXT)

		cmd->x = x;
	cmd->y = y;
	cmd->w = w;
	cmd->len = len;
	cmd->strSz = (unsigned int)strlen(text) + 1;

	void* strStart = R_GetCommandBuffer(cmd->strSz);
	strncpy((char*)strStart, text, cmd->strSz - 1);
}

SLT_API void DC_DrawImage(unsigned int imgId, float x, float y, float w, float h, float scale, uint8_t flipBits, float ox, float oy) {
	GET_COMMAND(drawImageCommand_t, RC_DRAW_IMAGE)
		cmd->x = x;
	cmd->y = y;
	cmd->w = w;
	cmd->h = h;
	cmd->ox = ox;
	cmd->oy = oy;
	cmd->scale = scale;
	cmd->flipBits = flipBits;
	cmd->imgId = imgId;
}

SLT_API void DC_DrawSprite(unsigned int spr, int id, float x, float y, float scale, uint8_t flipBits, int w, int h) {
	GET_COMMAND(drawSpriteCommand_t, RC_DRAW_SPRITE);
	cmd->spr = spr;
	cmd->id = id;
	cmd->x = x;
	cmd->y = y;
	cmd->scale = scale;
	cmd->flipBits = flipBits;
	cmd->w = w;
	cmd->h = h;
}

SLT_API void DC_DrawLine(float x1, float y1, float x2, float y2) {
	GET_COMMAND(drawLineCommand_t, RC_DRAW_LINE);
	cmd->x1 = x1;
	cmd->y1 = y1;
	cmd->x2 = x2;
	cmd->y2 = y2;
}

SLT_API void DC_DrawCircle(float x, float y, float radius, bool outline) {
	GET_COMMAND(drawCircleCommand_t, RC_DRAW_CIRCLE);
	cmd->outline = outline;
	cmd->x = x;
	cmd->y = y;
	cmd->radius = radius;
}

SLT_API void DC_DrawTri(float x1, float y1, float x2, float y2, float x3, float y3, bool outline) {
	GET_COMMAND(drawTriCommand_t, RC_DRAW_TRI);
	cmd->outline = outline;
	cmd->x1 = x1;
	cmd->y1 = y1;
	cmd->x2 = x2;
	cmd->y2 = y2;
	cmd->x3 = x3;
	cmd->y3 = y3;
}

SLT_API void DC_DrawMapLayer(unsigned int mapId, unsigned int layer, float x, float y, unsigned int cellX, unsigned int cellY, unsigned int cellW, unsigned int cellH)
{
	GET_COMMAND(drawMapCommand_t, RC_DRAW_MAP_LAYER);
	cmd->mapId = mapId;
	cmd->layer = layer;
	cmd->x = x;
	cmd->y = y;
	cmd->cellX = cellX;
	cmd->cellY = cellY;
	cmd->cellW = cellW;
	cmd->cellH = cellH;
}