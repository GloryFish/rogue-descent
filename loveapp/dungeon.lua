-- 
--  dungeon.lua
--  rogue-descent
--  
--  Created by Jay Roberts on 2012-02-24.
--  Copyright 2012 GloryFish.org. All rights reserved.
-- 

require 'middleclass'
require 'vector'
require 'room'

Dungeon = class('Dungeon')

function Dungeon:initialize()
  self:reset()
end

function Dungeon:reset()
  self.rooms = {}
  self.roomSize = vector(640, 320)
  
  local startingRoom = Room(Destination(1, 1), vector(0, 0), self.roomSize)
  
  self.rooms[startingRoom.destination.id] = startingRoom
  self.currentRoom = startingRoom
end

function Dungeon:idForLevelAndIndex(level, index)
  return ((level - 1) * level / 2) + index	
end

function Dungeon:positionForRoomAtDestination(destination)
  assert(instanceOf(Destination, destination), 'destination must be a Destination object')
  local level = destination.level
  local index = destination.index

  return vector((-level * self.roomSize.x / 2) + (self.roomSize.x / 2) + (self.roomSize.x * index) - self.roomSize.x,
                level * self.roomSize.y - self.roomSize.y)
end

function Dungeon:setCurrentRoom(destination)
  assert(instanceOf(Destination, destination), 'destination must be a Destination object')
  
  local room = self.rooms[destination.id]
  if room == nil then
    local position = self:positionForRoomAtDestination(destination)
    room = Room(destination, position, self.roomSize)
    self.rooms[destination.id] = room 
    print('Created new room')
    
  else
    print('Found existing room')
  end

  assert(room ~= nil, 'couldn\'t make a valid room')
  
  self.currentRoom = room
end

function Dungeon:update(dt)
  -- for index, room in pairs(self.rooms) do
  --   room:update(dt)
  -- end
end

function Dungeon:draw()
  for index, room in pairs(self.rooms) do
    room:draw()
  end
end