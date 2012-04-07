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

scenes.game = Gamestate.new()

local scene = scenes.game

function scene:enter(pre)
  self.dungeon = Dungeon()
	self.player = Player()
	self.camera = Camera()
	self.camera.deadzone = 0
	self.logger = Logger()
	
	local roomCenter = vector(self.dungeon.currentRoom.size.x / 2, self.dungeon.currentRoom.size.y / 2)
	self.player.position = self.dungeon.currentRoom.position + vector(roomCenter.x, 287)
	self.camera.position = roomCenter
	Notifier:listenForMessage('door_selected', self)
	Notifier:listenForMessage('mouse_up', self)
end

function scene:keypressed(key, unicode)
  if key == 'escape' then
    self:quit()
  end
  
  if key == ' ' then
    self.camera:shake(0.5, 0.5)
  end
end

function scene:mousepressed(x, y, button)
end

function scene:mousereleased(x, y, button)
  Notifier:postMessage('mouse_up', self.camera:screenToWorld(vector(x, y)))  
end

function scene:receiveMessage(message, data)
  if message == 'door_selected' then
    local door = data
    
    print(string.format('got the message'))
    print(door.room)
    print(self.dungeon.currentRoom)
    
    if door.room == self.dungeon.currentRoom or  -- Player can only activate a door in the current room
       door.destination == self.dungeon.currentRoom.destination then -- Or the matching door in the adjoining room
        print(string.format('setting dest: %s', tostring(door.destination)))
        local previousDestination = self.dungeon.currentRoom.destination
        self.dungeon:setCurrentRoom(door.destination)
        self.dungeon.currentRoom:unlockDoorTo(previousDestination)
        
        local path = self.dungeon:pathBetweenAdjacentDestinations(previousDestination, door.destination)
        self.player:followPath(path)
    end
  end
  
  if message == 'mouse_up' then
    local position = data
    
    print('Mouse up world: '..tostring(position))
    
    -- Are player and click in current room? 
    if self.dungeon.currentRoom:containsPoint(self.player.position) and self.dungeon.currentRoom:containsPoint(position) then
      -- Yes. Get a path to the click location
      local path = self.dungeon.currentRoom:pathBetweenPoints(self.player.position, position)

      if path ~= nil then
        self.player:followPath(path)
      else
        print 'No path'
      end

    else
      -- No. find the adjoining room.
      print('player or point not in this room')
      -- If found, get a path to the door, then get a path form the door to the click location
    end
  end
  
end

function scene:update(dt)
  self.logger:update(dt)
  self.logger:addLine('FPS: '..love.timer.getFPS())

  local world = self.camera:screenToWorld(vector(love.mouse.getX(), love.mouse.getY()))
  self.logger:addLine('Screen: '..tostring(vector(love.mouse.getX(), love.mouse.getY())))
  self.logger:addLine('World: '..tostring(world))
  local tile = self.dungeon.currentRoom:toTileCoords(world)
  self.logger:addLine('Tile: '..tostring(tile))
  
  if self.dungeon.currentRoom:tilePointIsWalkable(tile) then
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
  spritesheet.batch:clear()
  
  self.camera:apply()

  self.dungeon:draw()
  self.player:draw()

  love.graphics.draw(spritesheet.batch)
  
  self.camera:unapply()
  
  self.logger:draw()
end

function scene:quit()
  love.event.push('q')
end

function scene:leave()
end
