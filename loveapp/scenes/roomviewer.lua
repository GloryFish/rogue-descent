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
require 'room'

scenes.roomviewer = Gamestate.new()

local scene = scenes.roomviewer

function scene.enter(self, pre)
	self.room = Room()
	self.room.position = vector((love.graphics.getWidth() / 2) - (self.room.size.x / 2), (love.graphics.getHeight() / 2) - (self.room.size.y / 2))
end

function scene.keypressed(self, key, unicode)
  if key == 'escape' then
    self:quit()
  end
end

function scene.mousepressed(self, x, y, button)
end

function scene.mousereleased(self, x, y, button)
end

function scene.update(self, dt)
  if love.mouse.isDown('l') then
  end

  self.room:update(dt)
end

function scene.draw(self)
  self.room:draw()

end

function scene.quit(self)
end

function scene.leave(self)
end
