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

function scene:enter(pre)

end

function scene:keypressed(key, unicode)
  if key == 'escape' then
    self:quit()
  end
end

function scene:mousepressed(x, y, button)
end

function scene:mousereleased(x, y, button)
end

function scene:update(dt)
  if love.mouse.isDown('l') then
  end
end

function scene:draw()
end

function scene:quit()
end

function scene:leave()
end
