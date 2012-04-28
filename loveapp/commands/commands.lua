--
--  commands.lua
--  rogue-descent
--
--  A set of commands for rogue-descent.
--
--  Created by Jay Roberts on 2012-04-27.
--  Copyright 2012 GloryFish.org. All rights reserved.
--

require 'utility'
require 'vector'
require 'destination'

local commands = {
  ppos = {
    description = 'Sets the player\'s position manually',
    callback = function(delegate, ...)
      local x = tonumber(arg[1])
      local y = tonumber(arg[2])

      if x == nil or y == nil then
        return 'Invalid argument'
      end

      if delegate == nil or delegate.player == nil then
        return 'Error: player not found'
      else
        delegate.player.position = vector(x, y)
      end
    end,
    
  },
  
  objects = {
    description = 'Print a list of all objects in the current room',
    callback = function(delegate, ...)
      if delegate == nil or 
         delegate.dungeon == nil or
         delegate.dungeon.currentRoom == nil then
        return 'Error: player not found'
      else
        local names = {}
        for i, object in ipairs(delegate.dungeon.currentRoom.objects) do
          table.insert(names, object.name)
        end

        if #names == 0 then
          return 'No objects'
        else
          return names
        end
      end
    end,
  },
  
  shader = {
    description = 'Set the current pixel shader effect',
    callback = function(delegate, ...)
      local name = arg[1]
      
      if name == nil then
        current_effect = nil
        return 'No effect'
      end
    
      if name == 'list' then
        local items = {}
        for shaderName, shader in pairs(shaders.shaders) do
          table.insert(items, shaderName)
        end
        return items
      end
      
      if not shaders:isEffect(name) then
        return 'Invalid effect: '..name
      end
    
      current_effect = name
      return 'Effect: '..name
    end,
  },
  
}

return commands