#include <cstring>
#include "public.h";
#include "duktape/duktape.h";
#include "duktape/duk_module_duktape.h";
#include "duktapeapi.h";
#include "game.h"
#include "draw.h"

duk_ret_t duktape_trap_print(duk_context* ctx) {
	const char *str = duk_get_string(ctx, 0);
	trap->Print("%s", str);
	return 0;
}

duk_ret_t duktape_trap_error(duk_context *ctx) {
	int error = duk_get_int(ctx, 0);
	const char *str = duk_get_string(ctx, 1);
	trap->Error(error, str);
	return 0;
}

duk_ret_t duktape_trap_console(duk_context *ctx) {
	const char *str = duk_get_string(ctx, 1);
	trap->SendConsoleCommand(str);
	return 0;
}

duk_ret_t duktape_asset_create(duk_context *ctx) {
	AssetType_t assetType = (AssetType_t)duk_get_int(ctx, 0);
	const char *name = duk_get_string(ctx, 1);
	const char *path = duk_get_string(ctx, 2);
	int flags = duk_get_int(ctx, 3);

	AssetHandle handle = trap->Asset_Create(assetType, name, path, flags);
	duk_push_int(ctx, handle);
	return 1;
}

duk_ret_t duktape_asset_bmpfntset(duk_context *ctx) {
	AssetHandle handle = (AssetHandle)duk_get_int(ctx, 0);
	const char *glyphs = duk_get_string(ctx, 1);
	int glyphWidth = duk_get_int(ctx, 2);
	int charSpacing = duk_get_int(ctx, 3);
	int spaceWidth = duk_get_int(ctx, 4);
	int lineHeight = duk_get_int(ctx, 4);

	trap->Asset_BMPFNT_Set(handle, glyphs, glyphWidth, charSpacing, spaceWidth, lineHeight);
	return 0;
}

duk_ret_t duktape_asset_loadall(duk_context *ctx) {
	trap->Asset_LoadAll();
	return 0;
}

duk_ret_t duktape_dc_drawline(duk_context* ctx) {
	float x1 = (float)duk_get_number(ctx, 0);
	float y1 = (float)duk_get_number(ctx, 1);
	float x2 = (float)duk_get_number(ctx, 2);
	float y2 = (float)duk_get_number(ctx, 3);

	DC_DrawLine(x1, y1, x2, y2);
	return 0;
}

duk_ret_t duktape_dc_setcolor(duk_context* ctx) {
	byte r = (byte)duk_get_int(ctx, 0);
	byte g = (byte)duk_get_int(ctx, 1);
	byte b = (byte)duk_get_int(ctx, 2);
	byte a = (byte)duk_get_int(ctx, 3);
	
	DC_SetColor(r, g, b, a);
	return 0;
}

duk_ret_t duktape_dc_submit(duk_context* ctx) {
	DC_Submit();
	return 0;
}

duk_ret_t duktape_dc_clear(duk_context* ctx) {
	DC_Clear();
	return 0;
}

duk_ret_t duktape_dc_image(duk_context* ctx) {
	AssetHandle imgId = (AssetHandle)duk_get_int(ctx, 0);
	float x = (float)duk_get_number(ctx, 1);
	float y = (float)duk_get_number(ctx, 2);
	float w = (float)duk_get_number(ctx, 3);
	float h = (float)duk_get_number(ctx, 4);
	float alpha = (float)duk_get_number(ctx, 5);
	float scale = (float)duk_get_number(ctx, 6);
	byte flipBits = (byte)duk_get_int(ctx, 7);
	float ox = (float)duk_get_number(ctx, 8);
	float oy = (float)duk_get_number(ctx, 9);

	DC_DrawImage(imgId, x, y, w, h, alpha, scale, flipBits, ox, oy);
	return 0;
}

typedef struct {
	const char* object;
	const char* functionName;
	int nargs;
	duk_c_function func;
} duktape_function_t;

// these have to be kept grouped by object!!
static const duktape_function_t functions[] = {
	{ "Trap",	"print",		1,	duktape_trap_print },
	{ "Trap",	"error",		2,	duktape_trap_error },
	{ "Trap",	"console",		1,	duktape_trap_console },

	{ "Asset",	"create",		4,	duktape_asset_create },
	{ "Asset",	"bmpFntSet",	6,	duktape_asset_bmpfntset },
	{ "Asset",	"loadAll",		0,	duktape_asset_loadall },

	{ "Draw",	"line",			4,	duktape_dc_drawline },
	{ "Draw",	"setColor",		4,	duktape_dc_setcolor },
	{ "Draw",	"submit",		0,	duktape_dc_submit },
	{ "Draw",	"clear",		0,	duktape_dc_clear },
	{ "Draw",	"image",		10,	duktape_dc_image },
};
static const int functionsCount = sizeof(functions) / sizeof(duktape_function_t);

void Duktape_RegisterFunctions(duk_context* ctx) {
	duk_push_global_object(ctx);

	const char* currentObject = nullptr;
	for (int i = 0; i < functionsCount; i++) {
		const duktape_function_t &func = functions[i];

		if (!currentObject || strcmp(func.object, currentObject) != 0) {
			if (currentObject) {
				// now put the current object on the global
				duk_put_prop_string(ctx, -2, currentObject);
			}

			// make an object for the new global
			duk_push_object(ctx);
			currentObject = func.object;
		}

		duk_push_c_function(ctx, func.func, func.nargs);
		duk_put_prop_string(ctx, -2, func.functionName);
	}

	if (currentObject) {
		duk_put_prop_string(ctx, -2, currentObject);
	}

	// pop off the global object
	duk_pop(ctx);
}

duk_ret_t mod_search(duk_context *ctx) {
	const char *name = duk_get_string(ctx, 0);

	char *script = nullptr;
	const char *path = va("scripts/%s.js", name);

	int sz = trap->FS_ReadFile(path, (void**)&script);
	if (sz > 0) {
		duk_push_string(ctx, script);
		return 1;
	}
	return 0;
}

void Duktape_Init_Modules(duk_context *ctx) {
	// init modules
	duk_module_duktape_init(ctx);

	// push the modsearch function
	duk_get_global_string(ctx, "Duktape");
	duk_push_c_function(ctx, mod_search, 4);
	duk_put_prop_string(ctx, -2, "modSearch");
	duk_pop(ctx);
}

duk_context* Duktape_Init(const char* mainScriptName, const char* constructorStr) {
	duk_context* ctx = duk_create_heap_default();

	Duktape_Init_Modules(ctx);

	// load main script
	char *mainStr;
	int mainSz = trap->FS_ReadFile(mainScriptName, (void**)&mainStr);
	if (mainSz <= 0) {
		trap->Error(ERR_DROP, "duktape error: couldn't load %s", mainScriptName);
		return nullptr;
	}

	int ret = duk_peval_lstring(ctx, mainStr, mainSz);

	if (ret != 0) {
		trap->Error(ERR_DROP, "duktape error: couldn't compile %s", duk_safe_to_string(ctx, -1));
		return nullptr;
	}
	duk_pop(ctx); // bye bye retval

	free(mainStr);

	Duktape_RegisterFunctions(ctx);

	// call init
	duk_push_global_object(ctx);
	duk_get_prop_string(ctx, -1, "init");
	if (duk_pcall(ctx, 0) == DUK_EXEC_ERROR) {
		trap->Error(ERR_DROP, duk_safe_to_string(ctx, -1));
		return nullptr;
	} else {
		duk_pop(ctx); // pop retval
	}

	return ctx;
}

void Duktape_Update(duk_context* ctx, double dt) {
	// get the global update function
	duk_push_global_object(ctx);
	duk_get_prop_string(ctx, -1, "update");

	// push dt arg
	duk_push_number(ctx, dt);

	if (duk_pcall(ctx, 1) == DUK_EXEC_ERROR) {
		trap->Print("%s\n", duk_safe_to_string(ctx, -1));
	} else {
		duk_pop(ctx); // pop retval
	}

	duk_pop(ctx); // pop global
}

void Duktape_Draw(duk_context* ctx, int w, int h) {
	// get the global draw function
	duk_push_global_object(ctx);
	duk_get_prop_string(ctx, -1, "draw");

	// push args
	duk_push_number(ctx, w);
	duk_push_number(ctx, h);

	if (duk_pcall(ctx, 2) == DUK_EXEC_ERROR) {
		trap->Print("%s\n", duk_safe_to_string(ctx, -1));
	} else {
		duk_pop(ctx); // pop retval
	}

	duk_pop(ctx); // pop global
}