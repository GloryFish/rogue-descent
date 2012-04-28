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
  self.color.a = 220
  
  self.delegate = nil
  
  self:loadCommands()
end

function Console:loadCommands()
  self.commands = {}
  
  local filelist = love.filesystem.enumerate('commands')

  local count = 0

  for i, filename in ipairs(filelist) do
    local commands = require('commands/'..filename:sub(1, -5))
    
    for name, callback in pairs(commands) do
      self.commands[name] = callback
      count = count + 1
    end
  end
  
  print('Loaded '..count..' commands')
end

function Console:keypressed(key, unicode)
  if self.isOpen then
    if key == '`' or key == 'escape' then
      self:close()
      return true
    end
    
    if key == 'return' then
      self:runCommand(self.commandBuffer)
      return true
    end
    
    if key == 'backspace' then
      self.commandBuffer = self.commandBuffer:sub(1, -2)
      return true
    end
    
    if string.match(key, '[%l%d%s]') then
      self.commandBuffer = self.commandBuffer..key
      return true
    end
    
    return true
  end

  return false
end

function Console:runCommand(commandString)
  -- Parse the input string
  local parts = commandString:split(' ')
  
  local commandName = ''
  local args = {}
  table.insert(args, self.delegate)
  for i, part in ipairs(parts) do
    if i == 1 then
      commandName = part
    else
      table.insert(args, part)
    end
  end
  
  -- Run the command
  if self.commands[commandName] ~= nil then
    local success, lines = self.commands[commandName](unpack(args))
    
    if lines ~= nil then
      if type(lines) == 'string' then
        -- Add this to the output here
      else
        for i, line in ipairs(lines) do
          -- Add this to the output here
        end
      end
    end
    
    if success then
      print('OK')
    else
      print('ERROR')
    end
  else
    print('Command not found')
  end

  self.commandBuffer = ''
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
  
  local top = math.floor(self.topPosition)
  
  colors.white:set()
  love.graphics.line(0, top, love.graphics.getWidth(), top)

  self.color:set()
  love.graphics.rectangle('fill', 0, top, love.graphics.getWidth(), love.graphics.getHeight())

  colors.white:set()
  love.graphics.print(self.commandBuffer, 20, self.topPosition + 20)

end

return Console()