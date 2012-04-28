-- 
--  shaders.lua
--  rogue-descent
--  
--  Created by Jay Roberts on 2012-04-27.
--  Copyright 2012 GloryFish.org. All rights reserved.
-- 

require 'middleclass'

local Shaders = class('Shaders')

function Shaders:initialize()
  self.shaders = {}
  
  local filelist = love.filesystem.enumerate('effects')

  local count = 0

  for i, filename in ipairs(filelist) do
    local shader = {
      fragment = love.filesystem.read('effects/'..filename)
    }
    
    local success, effect = pcall(love.graphics.newPixelEffect, shader.fragment)
		
    if success then
      shader.effect = effect
      shader.externs = {}
      -- Find all externs used by this effect
      for type, name in shader.fragment:gmatch("extern (%w+) (%w+)") do
        table.insert(shader.externs, name)
      end
      
			self.shaders[filename:sub(1, -6)] = shader
      count = count + 1
		else
			print(string.format("Error loading shader (%s):\n", filename), effect)
		end
  end
  
  print('Loaded '..count..' effects')
end

function Shaders:isEffect(name)
  for shaderName, shader in pairs(self.shaders) do
    if shaderName == name then
      return true
    end
  end
  return false
end

function Shaders:set(name)
  if self.shaders[name] ~= nil then
    local shader = self.shaders[name]
    -- Send externs
    for i, extern in ipairs(shader.externs) do
      if extern == 'time' then
        shader.effect:send('time', love.timer.getTime())
      elseif extern == 'textureSize' then
        shader.effect:send('textureSize', {love.graphics.getWidth(), love.graphics.getHeight()})
      end
    end
    
    love.graphics.setPixelEffect(self.shaders[name].effect)
  else
    love.graphics.setPixelEffect()
  end
end

function Shaders:send(name, identifier, number)
end

return Shaders()