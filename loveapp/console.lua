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
  self.outputLines = {}
  self.maxLines = 14
  self.commandHistory = {}
  self.maxHistory = 20
  self.historyIndex = 0
  
  
  table.insert(self.outputLines, 'Type \'help\' for a list of available commands')
  
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
    
    -- Process up/down here
    if key == 'up' then
      self.historyIndex = self.historyIndex + 1
      if self.historyIndex > #self.commandHistory then
        self.historyIndex = #self.commandHistory
      end
      
      if self.commandHistory[self.historyIndex] ~= nil then
        self.commandBuffer = self.commandHistory[self.historyIndex]
      end
      return true
    end

    if key == 'down' then
      self.historyIndex = self.historyIndex - 1
      if self.historyIndex < 1 then
        self.commandBuffer = ''
      else
        self.commandBuffer = self.commandHistory[self.historyIndex]
      end
      
      if self.historyIndex < 0 then
        self.historyIndex = 0
      end
      
      return true
    end
    
    if string.match(key, '[%l%d%s-]') then
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
  
  if commandName == '' then
    return
  end

  table.insert(self.commandHistory, 1, commandString)
  
  if commandName == 'help' then
    self:help()
    self.commandBuffer = ''
    return
  end
  
  -- Run the command
  if self.commands[commandName] ~= nil then
    local lines = self.commands[commandName].callback(unpack(args))
    
    if lines ~= nil then
      if type(lines) == 'string' then
        -- Add this to the output here
        table.insert(self.outputLines, lines)
      else
        for i, line in ipairs(lines) do
          -- Add this to the output here
          table.insert(self.outputLines, line)
        end
      end
    end
  else
    table.insert(self.outputLines, 'Invalid command: '..commandName)
  end

  self.historyIndex = 0
  self.commandBuffer = ''
end

function Console:help()
  table.insert(self.outputLines, 'help - Display this screen')
  
  for commandName, command in pairs(self.commands) do
    table.insert(self.outputLines, commandName..' - '..command.description)
  end
end

function Console:update(dt)
  -- Truncate lines table
  if #self.outputLines > self.maxLines then
    for i = 1, #self.outputLines - self.maxLines do
      table.remove(self.outputLines, 1)
    end
  end

  -- Truncate command history table
  if #self.commandHistory > self.maxHistory then
    for i = 1, #self.commandHistory - self.maxHistory do
      table.remove(self.commandHistory, 1)
    end
  end
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
  
  -- Dark background
  self.color:set()
  love.graphics.rectangle('fill', 0, top, love.graphics.getWidth(), love.graphics.getHeight())
  
  -- Command dividers
  love.graphics.setLineStyle('rough')
  colors.white:set()
  love.graphics.line(0, top, love.graphics.getWidth(), top)

  colors.grey:set()
  love.graphics.line(0, top + 30, love.graphics.getWidth(), top + 30)

  -- Command buffer
  colors.white:set()
  love.graphics.print('> '..self.commandBuffer..'_', 20, self.topPosition + 10)
  
  local offset = 40
  local padding = 25
  
  for i = #self.outputLines, 1, -1 do
    love.graphics.print(self.outputLines[i], 20, self.topPosition + offset)
    offset = offset + padding
  end
end

return Console()