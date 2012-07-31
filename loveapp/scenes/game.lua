--
--  game.lua
--  rogue-descent
--
--  Created by Jay Roberts on 2012-02-27.
--  Copyright 2012 GloryFish.org. All rights reserved.
--

require 'logger'
require 'vector'
require 'colors'
require 'dungeon'
require 'camera'
require 'player'
require 'notifier'

local scene = Gamestate.new()

function scene:enter(pre)
  console.delegate = self

  self.dungeon = Dungeon()
	self.player = Player()
	self.camera = Camera()
	self.camera.deadzone = 0
	self.logger = Logger()

	local roomCenter = vector(self.dungeon.currentRoom.size.x / 2, self.dungeon.currentRoom.size.y / 2)
	self.player.position = vector(336, 272)
	self.camera.position = roomCenter
	Notifier:listenForMessage('door_unlocked', self)
	Notifier:listenForMessage('mouse_up', self)
end

function scene:keypressed(key, unicode)
  if console:keypressed(key, unicode) then
    return
  end

  if key == 'escape' then
    self:quit()
  end

  if key == ' ' then
    self.camera:shake(0.5, 0.5)
  end

  if key == '`' then
    console:open()
  end
end

function scene:mousepressed(x, y, button)
end

function scene:mousereleased(x, y, button)
  Notifier:postMessage('mouse_up', self.camera:screenToWorld(vector(x, y)))
end

function scene:receiveMessage(message, data)
  if message == 'door_unlocked' then
    local door = data

    -- when a door is unlocked, spawn its destination room and unlock the related door there
    local destinationRoom = self.dungeon:roomAt(door.destination)
    destinationRoom.visible = true
    destinationRoom:unlockDoorTo(door.room.destination)
  end

  if message == 'mouse_up' then
    local position = data

    if self.dungeon:positionIsWalkable(position) then
      local path = self.dungeon:pathBetweenPoints(self.player.position, position)
      if path ~= nil then
        self.player:followPath(path)
      end
    end

    -- -- Find the room the player is in
    --    local playerDest = self.dungeon:destinationForPosition(self.player.position)
    --    local playerRoom = self.dungeon:roomAt(playerDest)
    --
    --    -- and the room the click is in
    --    local clickDest = self.dungeon:destinationForPosition(position)
    --
    --    if playerDest.id == clickDest.id then
    --      -- player and click location are in the same room we can use a single path
    --      local path = playerRoom:pathBetweenPoints(self.player.position, position)
    --      if path ~= nil then
    --        self.player:followPath(path)
    --      end
    --    else
    --      -- Right now, assume the rooms are adjacent
    --      local clickRoom = self.dungeon:roomAt(clickDest)
    --
    --      -- Get path from position to door
    --      local playerDoor = playerRoom:getDoorTo(clickRoom.destination)
    --      local path = playerRoom:pathBetweenPoints(self.player.position, playerDoor.center)
    --
    --      -- Get path from door to click
    --      local clickDoor = clickRoom:getDoorTo(playerRoom.destination)
    --      local secondPath = clickRoom:pathBetweenPoints(clickDoor.center, position)
    --
    --      if path ~= nil and secondPath ~= nil then
    --        for i, location in ipairs(secondPath) do
    --          table.insert(path, location)
    --        end
    --
    --        self.player:followPath(path)
    --      end
    --
    --    end
  end

end

function scene:update(dt)
  stats:update(dt)
  console:update(dt)

  self.logger:update(dt)
  self.logger:addLine('FPS: '..love.timer.getFPS())

  local world = self.camera:screenToWorld(vector(love.mouse.getX(), love.mouse.getY()))
  self.logger:addLine('Screen: '..tostring(vector(love.mouse.getX(), love.mouse.getY())))
  self.logger:addLine('World: '..tostring(world))

  local playerDest = self.dungeon:destinationForPosition(self.player.position)
  self.dungeon.currentRoom = self.dungeon:roomAt(playerDest)

  if self.dungeon:positionIsWalkable(world) then
    self.logger:addLine('Walkable')
  end

  local count = 0
  for k, v in pairs(self.dungeon.rooms) do
    count = count + 1
  end
  self.logger:addLine(string.format('Rooms: %i', count))
  self.logger:addLine(string.format('Neighbors: %i', #self.dungeon:getNeighborhood(self.dungeon.currentRoom.destination)))

  self.dungeon:update(dt)

  self.camera.focus = vector(self.dungeon.currentRoom.position.x + self.dungeon.currentRoom.size.x / 2, self.dungeon.currentRoom.position.y + self.dungeon.currentRoom.size.y / 2)

  self.player:update(dt)

  self.camera:update(dt)
end

function scene:draw()
  shaders.focus = self.camera:worldToScreen(self.player.position)
  shaders:preDraw()

  sprites.main.batch:clear()

  self.camera:apply()

  self.dungeon:draw()
  self.player:draw()

  love.graphics.draw(sprites.main.batch)

  if vars.showpaths then
    -- Draw player path
    colors.yellow:set()
    for i, location in ipairs(self.player.path) do
      love.graphics.circle('fill', location.x, location.y, 10)
    end
    colors.white:set()

  end


  self.camera:unapply()

  shaders:postDraw(current_effect)

  self.logger:draw()
  stats:draw()
  console:draw()
end

function scene:quit()
  love.event.push('quit')
end

function scene:leave()
end

return scene