-- 
--  console.lua
--  rogue-descent
--  
--  Created by Jay Roberts on 2012-04-27.
--  Copyright 2012 GloryFish.org. All rights reserved.
-- 

require 'middleclass'
require 'vector'
require 'rectangle'
require 'colors'

local Console = class('Console')

function Console:initialize()
  self.isOpen = false
  self.commandBuffer = ''
  
  self.topAnchor = love.graphics.getHeight() / 2 -- This is where the top of the console is, set this to control the size
  self.topPosition = self.topAnchor -- This is the actual position, this changes as the console animates open
  
  self.color = colors.black:clone()
  self.color.a = 200
end

function Console:update(dt)
end

function Console:toggle()
  if self.isOpen then
    self:close()
  else
    self:open()
  end
end

function Console:open()
  self.isOpen = true
end

function Console:close()
  self.isOpen = false
end

function Console:draw()
  if not self.isOpen then
    return
  end
  
  colors.white:set()
  love.graphics.line(0, self.topPosition, love.graphics.getWidth(), self.topPosition)

  self.color:set()
  love.graphics.rectangle('fill', 0, self.topPosition, love.graphics.getWidth(), love.graphics.getHeight())

end

return Console()