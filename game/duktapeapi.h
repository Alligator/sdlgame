#pragma once
#include "duktape/duktape.h";

duk_context* Duktape_Init(const char* mainScriptName, const char* constructorStr);
void Duktape_Update(duk_context* ctx, double dt);
void Duktape_Draw(duk_context* ctx, int w, int h);