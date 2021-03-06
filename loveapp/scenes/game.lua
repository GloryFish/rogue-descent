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
require 'gesturerecognizer'
require 'notifier'

local scene = Gamestate.new()

function scene:enter(pre)
  console.delegate = self

  self.dungeon = Dungeon()
	self.player = Player()
	self.camera = Camera()
	self.camera.deadzone = 0
  self.camera.smoothMovement = false
	self.logger = Logger()
  self.gestureRecognizer = GestureRecognizer()

  Notifier:listenForMessage('door_unlocked', self)
  Notifier:listenForMessage('door_locked', self)
	Notifier:listenForMessage('mouse_up', self)
  Notifier:listenForMessage('mouse_drag', self)
  Notifier:listenForMessage('mouse_click', self)
  Notifier:listenForMessage('player_entered_room', self)

  self:reset()
end

function scene:reset()
  self.dungeon:reset()

  local roomCenter = vector(self.dungeon.currentRoom.size.x / 2, self.dungeon.currentRoom.size.y / 2)
  self.player.position = vector(336, 272)
  self.camera.position = roomCenter
  self.camera.focus = roomCenter
  Notifier:postMessage('player_entered_room', self.dungeon.currentRoom)
end

function scene:keypressed(key, unicode)
  if console:keypressed(key, unicode) then
    return
  end

  if key == 'escape' then
    self:quit()
  end

  if key == 's' then
    self.drawSaturation = not self.drawSaturation
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
end

function scene:receiveMessage(message, data)
  if message == 'door_unlocked' then
    local door = data

    -- when a door is unlocked, spawn its destination room and unlock the related door there
    local destinationRoom = self.dungeon:roomAt(door.destination)
    destinationRoom:unlockDoorTo(door.room.destination)
  end

  if message == 'door_locked' then
    local door = data

    -- when a door is locked, spawn its destination room and lock the related door there
    local destinationRoom = self.dungeon:roomAt(door.destination)
    destinationRoom:lockDoorTo(door.room.destination)
  end

  if message == 'mouse_drag' then
    local position = data
    self.camera.smoothMovement = false
    self.camera.focus = self.camera.focus - position
  end

  if message == 'mouse_click' then
    local position = data
    local worldPoint = self.camera:screenToWorld(position)

    if self.dungeon:positionIsWalkable(worldPoint) then
      local path = self.dungeon:pathBetweenPoints(self.player.position, worldPoint)
      if path ~= nil then
        self.player:followPath(path)
      end
    else
      -- Pass this on to other interested game objects
      Notifier:postMessage('world_click', worldPoint)
    end
  end

  if message == 'player_entered_room' then
    local room = data
    self.camera.smoothMovement = true
    self.camera.focus = vector(room.position.x + room.size.x / 2, room.position.y + room.size.y / 2)
  end

end

function scene:update(dt)
  stats:update(dt)
  console:update(dt)

  self.gestureRecognizer:update(dt)

  self.logger:update(dt)
  self.logger:addLine('FPS: '..love.timer.getFPS())

  local world = self.camera:screenToWorld(vector(love.mouse.getX(), love.mouse.getY()))
  self.logger:addLine('Screen: '..tostring(vector(love.mouse.getX(), love.mouse.getY())))
  self.logger:addLine('World: '..tostring(world))

  local playerDest = self.dungeon:destinationForPosition(self.player.position)
  self.dungeon:setCurrentRoom(playerDest)

  if self.dungeon:positionIsWalkable(world) then
    self.logger:addLine('Walkable')
  end

  local count = 0
  for k, v in pairs(self.dungeon.rooms) do
    count = count + 1
  end
  self.logger:addLine(string.format('Rooms: %i', count))
  self.logger:addLine(string.format('Neighbors: %i', #self.dungeon:getNeighborhood(self.dungeon.currentRoom.destination)))

  self.dungeon.focus = self.camera.focus
  self.dungeon:update(dt)

  self.player:update(dt)

  self.camera:update(dt)
end

function scene:draw()
  -- Draw saturation map
  love.graphics.setCanvas(canvases.saturation)

  canvases.saturation:clear()

  self.camera:apply()

  self.dungeon:draw('saturation')

  self.camera:unapply()

  love.graphics.setCanvas()

  if self.drawSaturation then

    love.graphics.draw(canvases.saturation, 0, 0)
    love.graphics.print('Saturation map', 10, 10)

  else
    local focus = self.camera:worldToScreen(self.player.position)
    shaders.focus = focus
    shaders.saturation_map = canvases.saturation
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
  end




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