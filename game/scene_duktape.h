#pragma once
#include "shared.h"
#include "duktape/duktape.h";

class DuktapeScene : public Scene {
public:
	DuktapeScene(const char *mainScriptName, const char *mapFileName)
		: mainScriptName(mainScriptName), mapFileName(mapFileName) {};
	void Startup(ClientInfo* i) override;
	void Update(double dt) override;
	void Render() override;
	~DuktapeScene();

	void Console(const char *str) override;
	ClientInfo* inf = nullptr;

private:
	const char *mainScriptName;
	const char *mapFileName;
	duk_context *ctx = nullptr;
	bool initialized = false;
};