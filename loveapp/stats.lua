--
--  stats.lua
--  rogue-descent
--
--  Created by Jay Roberts on 2012-05-02.
--  Copyright 2012 DesignHammer. All rights reserved.
--

require 'middleclass'
require 'vector'
require 'colors'

local Stats = class('Stats')

function Stats:initialize()
  self.interval = 1
  self.elapsed = 0
  
  self.size = vector(500, 200)

  self.position = vector(love.graphics.getWidth() - self.size.x - 30, 30)

  self.memory = {}
  table.insert(self.memory, 0)
  self.maxsize = math.floor(self.size.x / 2)
  self.xWidth = self.size.x / self.maxsize
  
  self.maxMemory = 0
end

function Stats:update(dt)
  self.elapsed = self.elapsed + dt
  if self.elapsed > self.interval then
    self:log()
    self.elapsed = self.elapsed - self.interval
  end
end

function Stats:log()
  if #self.memory > self.maxsize then
    table.remove(self.memory, 1)
  end
  local memory = collectgarbage('count')
  if memory > self.maxMemory then
    self.maxMemory = memory
  end

  print(tostring(memory))
  print(tostring(memory / self.maxMemory))

  table.insert(self.memory, memory)
end

function Stats:draw()
  if not vars.showstats then
    return
  end

  colors.white:set()
  love.graphics.line(self.position.x, self.position.y + self.size.y, self.position.x + self.size.x, self.position.y + self.size.y)
  
  local points = {}
  
  for i = 1, #self.memory do
    local currentMemory = self.memory[i]
    if currentMemory == nil then
      break
    end

    -- Draw memory graph
    -- Calculate local coordinates of graph with positiive Y moving up
    local currentX = math.floor((i - 1) * self.xWidth)
    local currentY = math.floor((currentMemory / self.maxMemory) * self.size.y)
    
    -- Transform to screen coordinates
    currentX = self.position.x + currentX + self.size.x - #self.memory * self.xWidth
    currentY = self.position.y + self.size.y - currentY
    
    table.insert(points, currentX)
    table.insert(points, currentY)
  end
  
  if #points >= 4 then
    colors.red:set()
    love.graphics.line(points)
    colors.white:set()
    love.graphics.print('memory: '..tostring(self.maxMemory), self.position.x + 10, self.position.y + self.size.y - 20)
  end
end

return Stats()