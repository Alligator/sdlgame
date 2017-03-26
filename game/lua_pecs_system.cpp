#include "lua_pecs_system.h"
#include "baseworld.h"
#include "public.h"

using namespace pecs;

LuaSystem::LuaSystem(sol::state &st, const char *name, int priority, int mask, sol::function func) : luaUpdate(func), lua(st)
{
	this->name = name;
	this->priority = priority;
	this->mask = mask;
}

void LuaSystem::update(double dt)
{
	BaseWorld *world = (BaseWorld*)this->world;

	for (auto &entity : world->entities) {
		PECS_SKIP_INVALID_ENTITY;

		auto components = lua.create_table_with();
		if (this->mask & COMPONENT_BODY) { components["body"] = &world->getBody(entity.id); }
		if (this->mask & COMPONENT_MOVABLE) { components["mov"] = &world->getMovable(entity.id); }
		if (this->mask & COMPONENT_RENDERABLE) { components["renderable"] = &world->getRenderable(entity.id); }

		this->luaUpdate(dt, entity, components);
	}
}

void LuaSystem::on_add(world_t * world)
{
}

void LuaSystem::on_remove(world_t * world)
{
}

void LuaSystem::on_add(entity_t * entity)
{
}

void LuaSystem::on_remove(entity_t * entity)
{
}