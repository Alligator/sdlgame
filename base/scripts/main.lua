require 'components'

-- FIXME: the rest of this hardcoded shit
local tmap = world:getTileMap(world.master_entity.id).map
local cam = Camera.new(1280, 720, 3, tmap.w * tmap.tile_width, tmap.h * tmap.tile_height)
cam.active = true
cam:Bind()
world:addCamera(world.master_entity, cam)

spawn_entity = function(world, obj, props)
    if obj.type == 'player' then
        local map = world:getTileMap(world.master_entity.id).map
        local camera = world:getCamera(world.master_entity.id)

        local ent = world:new_entity()
        local b = Body:new(obj.x + (map.tile_width / 2), obj.y - 14.001, 16, 15)
        world:addBody(ent, b)
        world:addMovable(ent, Movable:new(0, 0))
        world:addRenderable(ent, Renderable:new(200, 30, 30, 200))
        world:addPlayerInput(ent, PlayerInput:new())
        world:addPlayer(ent, Player:new())
        local playerImg = world:new_image("player", "gfx/dog.png")
        world:addSprite(ent, Sprite:new(playerImg, 22, 15, 0, 0))
        world:add_entity(ent)

        camera.target = ent.id
    elseif obj.type == 'goal' then
        local map = world:getTileMap(world.master_entity).map
        local ent = world:new_entity()
        local b = Body:new(obj.x, obj.y, 32, 32)
        world:addBody(ent, b)
        local bone = world:new_image("bone", "gfx/bone.png")
        world:addSprite(ent, Sprite:new(bone, 32, 32, 0, 0))
        world:addAnimation(ent, Animation:new(0, 0, 7, 0.1, world.time))
        world:add_entity(ent)
    else
        print("unhandled entity: " .. obj.type)
    end
end

world:add_system {
    name = "Camera Update",
    priority = 0,
    components = {COMPONENT_CAMERA},
    process = function(dt, ent, c)
        if c.camera.active == false then
            return
        end

        if c.camera.target < 0 then
            return
        end

        local body = world:getBody(c.camera.target)
        c.camera:Center(body.x, body.y)
        c.camera:Bind()
    end
}

world:add_system {
    name = "Player Update",
    priority = 0,
    components = {COMPONENT_PLAYERINPUT, COMPONENT_BODY, COMPONENT_MOVABLE, COMPONENT_PLAYER},
    process = function(dt, ent, c)
        if c.playerinput.right then
            c.body.x = c.body.x + 50 * dt
        end
        if c.playerinput.left then
            c.body.x = c.body.x - 50 * dt
        end
        if c.playerinput.up then
            c.body.y = c.body.y - 50 * dt
        end
        if c.playerinput.down then
            c.body.y = c.body.y + 50 * dt
        end
    end
}