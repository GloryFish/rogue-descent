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

function Dungeon:destinationForPosition(position)
  local level = math.floor(position.y / self.roomSize.y) + 1
  local index = math.floor(position.x / self.roomSize.x) + 1
  
  if level < 1 then
    return nil
  end
  
  if index < 1 then 
    return nil
  end
  
  if index > level then
    return nil
  end
  
  return Destination(level, index)
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
  
  local room = self:roomAt(destination)

  assert(instanceOf(Room, room), 'couldn\'t make a valid room')
  
  self.currentRoom = room
end

function Dungeon:roomAt(destination)
  local room = self.rooms[destination.id]
  if room == nil then
    local position = self:positionForRoomAtDestination(destination)
    room = Room(destination, position, self.roomSize)
    self.rooms[destination.id] = room 
    print('Created new room')
  else
    print('Found existing room')
  end
  
  return room
end

function Dungeon:update(dt)
  for index, destination in ipairs(self:getNeighborhood(self.currentRoom.destination)) do
    self.rooms[destination.id]:update(dt)
  end
end

-- Gives a set of destinations (that actually have rooms) in an area around a given destination
function Dungeon:getNeighborhood(destination)
 local spread = 3
 
 local neighborhood = {}
 
 for level = destination.level - spread, destination.level + spread do
   for index = destination.index - spread, destination.index + spread do
     if level > 0 and index > 0 and index <= level then
       local dest = Destination(level, index)
       if self.rooms[dest.id] ~= nil then
         table.insert(neighborhood, dest)
       end
     end
   end
 end
 return neighborhood
end


function Dungeon:draw()
  for index, destination in ipairs(self:getNeighborhood(self.currentRoom.destination)) do
    self.rooms[destination.id]:draw()
  end
end