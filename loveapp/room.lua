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
require 'door'

Room = class('Room')

function Room:initialize(level, index, position)
  assert(level ~= nil, 'Room intialized without level')
  assert(index ~= nil, 'Room intialized without index')
  assert(position ~= nil, 'Room intialized without position')
  
  self.position = position
  self.size = vector(0, 0)

  self.level = level
  self.index = index
  self.id = self:getId()

  self.doors = {
    left = Door(vector(self.position.x + 75, self.position.y + 300)),
    right = Door(vector(self.position.x + 625, self.position.y + 300)),
  }

  self.color = colors.white
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
  self.color:set()
  love.graphics.rectangle('line', self.position.x, self.position.y, self.size.x, self.size.y)
  
  for key, door in pairs(self.doors) do
    door:draw()
  end
  
  if debug then
    love.graphics.print(string.format('id: %s level: %s index: %s', self:getId(), self.level, self.index), 
                        self.position.x + 10, 
                        self.position.y + 10);
  end
end

