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
require 'destination'
require 'door'
require 'monster'

Room = class('Room')

function Room:initialize(destination, position, size)
  assert(instanceOf(Destination, destination), 'destination must be a Destination object')
  assert(position ~= nil, 'Room intialized without position')
  assert(size ~= nil, 'Room intialized without size')
  
  self.destination = destination
  self.level = self.destination.level
  self.index = self.destination.index
  self.position = position
  self.size     = size
  self.center = position + size / 2
  self.platforms = {}
  self.objects = {}

  self:generate()
end

-- Returns the nearest platform in a room to a supplied position
-- If none are available, returns the room's center
function Room:nearestPlatform(position)
  local nearest = nil
  local shortestDistance = 100000
  
  for index, platform in ipairs(self.platforms) do
    local vec = position - platform
    local dist = vec:len()
    if dist < shortestDistance then
      shortestDistance = dist
      nearest = platform
    end
  end
  
  if nearest ~= nil then
    return nearest
  else
    return self.center
  end
end

-- Generate a random room
function Room:generate()
  -- background and walls
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
  
  -- doors
  self.doors = {}
  
  -- ul
  if self.destination.index > 1 and self.destination.level > 1 then
    local pos = vector(self.position.x + 32 * 7, self.position.y)
    self.doors.ul = Door(pos, self, Destination(self.destination.level - 1, self.destination.index - 1))
  else
    self.doors.ul = nil
  end
    
  -- ur
  if self.destination.index < self.destination.level and self.destination.level > 1 then
    local pos = vector(self.position.x + self.size.x - 32 * 7, self.position.y)
    self.doors.ur = Door(pos, self, Destination(self.destination.level - 1, self.destination.index))
  else
    self.doors.ur = nil
  end
  
  -- ll
  local pos = vector(self.position.x + 32 * 3, self.position.y + self.size.y - 32)
  self.doors.ll = Door(pos, self, Destination(self.destination.level + 1, self.destination.index))
  
  -- lr
  pos = vector(self.position.x + self.size.x - 32 * 3, self.position.y + self.size.y - 32)
  self.doors.lr = Door(pos, self, Destination(self.destination.level + 1, self.destination.index + 1))
  
  -- Add platforms
  table.insert(self.platforms, vector(self.position.x + 16 + 32 * 5, self.position.y + self.size.y - 32))
  table.insert(self.platforms, vector(self.position.x + self.size.x - (32 * 5) + 16, self.position.y + self.size.y - 32))
  
  -- Add objects
  for i = 1, 5 do
    local monster = Monster(self.destination.level)
    monster.position = vector(self.position.x + 120 + (32 * #self.objects), self.position.y + 230)
    table.insert(self.objects, monster)    
  end
end

function Room:__tostring()
	return "Room ("..tonumber(self.destination.level)..","..tonumber(self.destination.index)..","..tonumber(self.destination.id)..") ("..tonumber(self.position.x)..","..tonumber(self.position.y)..")"
end

function Room:update(dt)
end

function Room:unlockDoorTo(destination)
  for key, door in pairs(self.doors) do
    if door.destination == destination then
      door.locked = false
    end
  end
end


function Room:draw()
  for x, column in ipairs(self.tiles) do
    for y, quadname in ipairs(column) do
      spritesheet.batch:addq(spritesheet.quads[quadname], 
                              self.position.x + ((x - 1) * 32), 
                              self.position.y + ((y - 1) * 32),
                              0,
                              2,
                              2)
    end
  end
  
  for name, door in pairs(self.doors) do
    door:draw()
  end

  for index, object in ipairs(self.objects) do
    object:draw()
  end
end

