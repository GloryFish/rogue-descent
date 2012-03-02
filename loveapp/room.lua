--
--  room.lua
--  rogue-descent
--
--  Created by Jay Roberts on 2012-02-23.
--  Copyright 2012 Jay Roberts. All rights reserved.
--

require 'middleclass'
require 'vector'
require 'rectangle'
require 'colors'
require 'spritesheets'


Room = class('Room')

function Room:initialize(level, index, position, size)
  assert(level ~= nil, 'Room intialized without level')
  assert(index ~= nil, 'Room intialized without index')
  assert(position ~= nil, 'Room intialized without position')
  assert(position ~= nil, 'Room intialized without size')
  
  self.level    = level
  self.index    = index
  self.position = position
  self.size     = size

  self.id = self:getId()
  
  self:generate()
  
  self.spritebatch = love.graphics.newSpriteBatch(spritesheet.texture, 1000)
end

-- Generate a random room
function Room:generate()
  self.tiles = {}
  
  local width = self.size.x / 32
  local height = self.size.y / 32

  for x = 1, width, 1 do 
    self.tiles[x] = {} 
    for y = 1, height, 1 do 
      if y == 1 or y == height or x == 1 or x == width then
        self.tiles[x][y] = 'wall_1' 
      else
        self.tiles[x][y] = 'background_1' 
      end
    end
  end
end

function Room:__tostring()
	return "Room ("..tonumber(self.level)..","..tonumber(self.index)..","..tonumber(self.id)..") ("..tonumber(self.position.x)..","..tonumber(self.position.y)..")"
end

function Room:getId()
	return ((self.level - 1) * self.level / 2) + self.index
end

function Room:update(dt)
end


function Room:draw()
  self.spritebatch:clear()
  
  colors.white:set()
  for x, column in ipairs(self.tiles) do
    for y, quadname in ipairs(column) do
      self.spritebatch:addq(spritesheet.quads[quadname], 
                            (x - 1) * 32, 
                            (y - 1) * 32,
                            0,
                            2,
                            2)
    end
  end

  love.graphics.draw(self.spritebatch)
  
  if debug then
    love.graphics.print(string.format('id: %s level: %s index: %s', self:getId(), self.level, self.index), 
                        math.floor(self.position.x + 10), 
                        math.floor(self.position.y + 10));
  end
end

