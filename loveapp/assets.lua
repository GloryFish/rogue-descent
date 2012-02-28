-- 
--  assets.lua
--  rogue-descent
--  
--  Created by Jay Roberts on 2012-02-24.
--  Copyright 2012 GloryFish.org. All rights reserved.
-- 

require 'middleclass'

local AssetsClass = class('AssetsClass')

function AssetsClass:initialize()
  self.images = {}
  
  for i, image in ipairs(self.images) do
    image:setFilter('nearest', 'nearest')
  end
  
end

function AssetsClass:getByName(name)
  if self.images[name] == nil then
    self.images[name] = love.graphics.newImage('resources/images/'..name..'.png')
  end
  return self.images[name]
end

Assets = AssetsClass()