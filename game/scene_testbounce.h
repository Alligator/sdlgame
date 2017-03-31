#pragma once
#include "../src/scene.h"
#include "baseworld.h"

class TestBounceScene : public Scene {
public:
	void Startup(ClientInfo* i) override;
	void Update(float dt) override;
	void Render() override;
	~TestBounceScene();

private:
	ClientInfo* inf;
	BaseWorld *world;
};