#include "duktape/duktape.h";
#include "scene_duktape.h"
#include "public.h"
#include "duktapeapi.h";

void DuktapeScene::Startup(ClientInfo* info) {
	ctx = Duktape_Init(mainScriptName, mapFileName);
	inf = info;
	if (ctx) {
		initialized = true;
		trap->Cvar_Set("com_errorMessage", ""); // huh?
	}
}

void DuktapeScene::Update(double dt) {
	Duktape_Update(ctx, dt);
}

void DuktapeScene::Render() {
	Duktape_Draw(ctx, inf->width, inf->height);
}

DuktapeScene::~DuktapeScene() {
	if (!initialized) {
		return;
	}

	duk_destroy_heap(ctx);
}

void DuktapeScene::Console(const char* str) {
}