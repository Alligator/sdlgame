#pragma once
#include <list>
#include <SDL/SDL.h>
#include <nanovg.h>
#include "local.h"

class Scene {
public:
	virtual void Startup(ClientInfo* i) = 0;
	virtual void Teardown() = 0;
	virtual void Update(double dt) = 0;
	virtual void Render() = 0;
};

class SceneManager {
private:
	std::list<Scene*> scenes;
	ClientInfo info;
public:
	SceneManager(ClientInfo i) {
		info = i;
	}

	void Switch(Scene* newScene) {
		for (auto s : scenes) {
			s->Teardown();
		}
		scenes.empty();
		Push(newScene);
	}

	void Update(double dt) {
		for (auto s : scenes) {
			s->Update(dt);
		}
	}

	void Render() {
		for (auto s : scenes) {
			s->Render();
		}
	}

	void Push(Scene* newScene) {
		scenes.push_back(newScene);
		newScene->Startup(&info);
	}

	void Pop() {
		if (scenes.size() == 0) {
			return;
		}

		auto lastScene = scenes.back();
		scenes.pop_back();
		lastScene->Teardown();
	}

	Scene* Current() {
		return scenes.back();
	}
};