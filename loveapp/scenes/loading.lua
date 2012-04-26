--
--  loading.lua
--  rogue-descent
--
--  Created by Jay Roberts on 2012-04-26.
--  Copyright 2012 Jay Roberts. All rights reserved.
--

require 'logger'
require 'vector'
require 'colors'
require 'rectangle'

local scene = Gamestate.new()

function scene:enter(pre)
  self.finished = false
end

function scene:keypressed(key, unicode)
end

function scene:mousepressed(x, y, button)
end

function scene:mousereleased(x, y, button)
end

function scene:update(dt)
  self.finished = true
  print('Finished loading')
  
  
  if self.finished then
    Gamestate.switch(scenes.game)
  end
end

function scene:draw()
end

function scene:quit()
end

function scene:leave()
end

return scene