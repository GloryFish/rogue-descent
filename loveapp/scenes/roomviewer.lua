--
--  roomviewer.lua
--  rogue-descent
--
--  Created by Jay Roberts on 2012-02-23.
--  Copyright 2012 Jay Roberts. All rights reserved.
--

require 'logger'
require 'vector'
require 'colors'
require 'camera'
require 'dungeon'

local scene = Gamestate.new()

function scene.enter(self, pre)
	self.dungeon = Dungeon()

	self.camera = Camera()
	self.camera.deadzone = 0
end

function scene.keypressed(self, key, unicode)
  if key == 'escape' then
    self:quit()
  end

  if key == 'a' then
    self.dungeon:goToLocationFromRoom('ll', self.dungeon.currentRoom)
  end
  if key == 'd' then
    self.dungeon:goToLocationFromRoom('lr', self.dungeon.currentRoom)
  end
  if key == 'q' then
    self.dungeon:goToLocationFromRoom('ul', self.dungeon.currentRoom)
  end
  if key == 'e' then
    self.dungeon:goToLocationFromRoom('ur', self.dungeon.currentRoom)
  end
end

function scene.mousepressed(self, x, y, button)
end

function scene.mousereleased(self, x, y, button)
end

function scene.update(self, dt)
  if love.mouse.isDown('l') then
  end

  self.dungeon:update(dt)

  self.camera.focus = vector(self.dungeon.currentRoom.position.x + self.dungeon.currentRoom.size.x / 2, self.dungeon.currentRoom.position.y + self.dungeon.currentRoom.size.y / 2)

  self.camera:update(dt)
end

function scene.draw(self)
  self.camera:apply()

  self.dungeon:draw()

  self.camera:unapply()
end

function scene.quit(self)
end

function scene.leave(self)
end

return scene