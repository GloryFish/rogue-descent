--
--  base.lua
--  rogue-descent
--
--  A base scene that can be used when creating new scenes.
--
--  Created by Jay Roberts on 2012-02-23.
--  Copyright 2012 Jay Roberts. All rights reserved.
--

require 'logger'
require 'vector'
require 'colors'
require 'rectangle'

scenes.base = Gamestate.new()

local scene = scenes.base

function scene.enter(self, pre)

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
end

function scene.draw(self)
end

function scene.quit(self)
end

function scene.leave(self)
end
