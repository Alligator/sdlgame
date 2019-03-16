#pragma once
#include "../src/shared.h"

class WrenScene : public Scene {
public:
	WrenScene(const char *mainScriptName, const char *mapFileName) : mainScriptName(mainScriptName), mapFileName(mapFileName) {};
	void Startup(ClientInfo* i) override;
	bool Update(double dt) override;
	void Render() override;
	~WrenScene();

	void Console(const char *str) override;
	ClientInfo* inf = nullptr;

private:
	const char *mainScriptName;
	const char *mapFileName;
	struct WrenVM *vm = nullptr;
	bool initialized = false;
};
