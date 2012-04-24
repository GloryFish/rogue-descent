--
--  spritesheets.lua
--  rogue-descent
--
--  Created by Jay Roberts on 2012-03-01.
--  Copyright 2012 GloryFish.org. All rights reserved.
--

require 'middleclass'

Spritesheet = class('Spritesheet')

function Spritesheet:initialize(name)
  self.texture = love.graphics.newImage('resources/sprites/'..name..'.png') 
  self.texture:setFilter('nearest', 'nearest')
  
  self.quads = {}
  
  local frameData = require('resources/sprites/'..name)
  local frames = frameData.getFrames()
  
  for name, frame in pairs(frames) do
    self.quads[frame.name] = love.graphics.newQuad(frame.rect.x, frame.rect.y, frame.rect.width, frame.rect.height, self.texture:getWidth(), self.texture:getHeight())
  end
  
  self.batch = love.graphics.newSpriteBatch(self.texture, 10000)
end


spritesheet = Spritesheet('spritesheet')
