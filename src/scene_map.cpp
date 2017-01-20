#include "scene_map.h"
#include <nanovg.h>
#include <tmx.h>
#include "sweep.h"
#include "local.h"

#include "glstuff/shaderquad.h"
#include "glstuff/shader.h"

#include "sys/systems_drw.h"
#include "sys/systems_upd.h"
#include "components.h"
#include "cvar_game.h"

GameWorld::GameWorld() {
	RegisterGameCvars();

	systems.add<InputSystem>();
	systems.add<PlayerSystem>();
	systems.add<CameraUpdateSystem>();
	systems.configure();
}

GameWorld::~GameWorld() {
	if (tmap != nullptr && tmap->map != nullptr) {
		tmx_map_free(tmap->map);
	}
}

bool GameWorld::Load(const char *filename) {
	tmx_map *map = tmx_load(filename);

	if (map == nullptr) {
		error = "Failed to load tmx";
		return false;
	}

	auto world = this->entities.create();
	auto tileMap = world.assign<TileMap>();
	tileMap->map = map;
	tmap = world.component<TileMap>().get();

	tmx_layer *layer = map->ly_head;
	while (layer) {
		if (layer->visible == false) {
			layer = layer->next;
			continue;
		}

		if (strcmp(layer->name, "world") == 0) {
			tileMap->worldLayer = layer;
		}

		if (layer->type == L_OBJGR) {
			SpawnEntitiesFromLayer(*layer, this->entities);
		}

		layer = layer->next;
	}

	if (tmap->worldLayer == nullptr) {
		Com_Error(ERR_DROP, "No layer named \"world\" found in map.");
	}

	if (map->tilecount > MAX_TILES) {
		Com_Error(ERR_DROP, "Too many tiles in map, raise MAX_TILES.");
	}

	for (unsigned int i = 1; i < map->tilecount; i++) {
		auto tile = map->tiles[i];
		if (tile == nullptr) {
			break;
		}
		auto &info = tmap->tinfo[i];
		info.gid = i;
		info.solid = true;
		info.platform = false;

		auto prop = tile->properties;
		while (prop != nullptr) {
			if (strcasecmp(prop->name, "solid") == 0) {
				info.solid = atoi(prop->value) > 0;
			}
			else if (strcasecmp(prop->name, "platform") == 0) {
				info.platform = atoi(prop->value) > 0;
			}
			prop = prop->next;
		}
				
	}

	auto shq = world.assign<ShaderQuad>();
	auto shader = new Shader();
	shader->LoadFromFile("shaders/default.frag", "shaders/default.vert");

	if (!shader->valid) {
		Com_Error(ERR_DROP, "problem constructing shader");
	}

	shq->AttachShader(shader);

	return true;
}

void GameWorld::update(ex::TimeDelta dt) {
	systems.update<InputSystem>(dt);
	systems.update<PlayerSystem>(dt);
	systems.update<CameraUpdateSystem>(dt);
}

// --------------------

MapScene::MapScene(const char *fileName) {
	this->fileName = fileName;
}

MapScene::~MapScene() {
	delete world;
	delete rendSys;
}

void MapScene::Startup(ClientInfo* info) {
	using namespace std::placeholders; // for `_1`

	inf = info;

	tmx_img_load_func = std::bind(&MapScene::nvg_img_load_func, this, _1);
	tmx_img_free_func = std::bind(&MapScene::nvg_img_free_func, this, _1);
	tmx_file_read_func = std::bind(&MapScene::physfs_file_read_func, this, _1, _2);;

	world = new GameWorld();
	auto success = world->Load(fileName);
	if (!success) {
		Com_Error(ERR_DROP, world->error);
		return;
	}

	rendSys = new ex::SystemManager(world->entities, world->events);
	rendSys->add<CameraDrawSystem>(inf);
	rendSys->add<TileMapDrawSystem>(inf);
	rendSys->add<RectDrawSystem>(inf);
	rendSys->configure();
}

void MapScene::Update(float dt) {
	world->update(dt);
}

void MapScene::Render() {
	rendSys->update<CameraDrawSystem>(0);
	rendSys->update<TileMapDrawSystem>(0);
	rendSys->update<RectDrawSystem>(0);
}

void* MapScene::nvg_img_load_func(const char *path) {
	void *buffer;
	auto sz = FS_ReadFile(path, &buffer);

	Img *img = new Img();
	img->nvg = inf->nvg;
	img->hnd = nvgCreateImageMem(img->nvg, NVG_IMAGE_NEAREST, (unsigned char *) buffer, sz);
	nvgImageSize(img->nvg, img->hnd, &img->w, &img->h);
	strncpy(img->path, path, sizeof(img->path));

	free(buffer);

	return (void*)img;
}

void MapScene::nvg_img_free_func(void *address) {
	Img *img = (Img*)address;
	nvgDeleteImage(img->nvg, img->hnd);
	delete img;
}

void* MapScene::physfs_file_read_func(const char *path, int *outSz) {
	void *xml;

	*outSz = FS_ReadFile(path, &xml);

	if (outSz < 0) {
		Com_Error(ERR_DROP, "Couldn't load file while parsing map %s", path);
		return nullptr;
	}

	return (void *)xml;
}