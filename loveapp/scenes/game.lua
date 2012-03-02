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
	
	self.player.position = self.dungeon.currentRoom.position + vector(self.dungeon.currentRoom.size.x / 2, self.dungeon.currentRoom.size.y / 2)
	Notifier:listenForMessage('door_selected', self)
end

function scene:keypressed(key, unicode)
  if key == 'escape' then
    self:quit()
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
    if door.room == self.dungeon.currentRoom then -- Player can only activate a door in the current room
      print(string.format('setting dest: %s', tostring(door.destination)))
      local previousDestination = self.dungeon.currentRoom.destination
      self.dungeon:setCurrentRoom(door.destination)
      self.dungeon.currentRoom:unlockDoorTo(previousDestination)
    end
      
  end
end

function scene:update(dt)
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
end

function scene:quit()
  love.event.push('q')
end

function scene:leave()
end
