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

function Dungeon:pathBetweenAdjacentDestinations(a, b)
  assert(instanceOf(Destination, a), 'a must be a Destination object')
  assert(instanceOf(Destination, b), 'a must be a Destination object')
  assert(self.rooms[a.id] ~= nil, 'a must be an existing room')
  assert(self.rooms[b.id] ~= nil, 'b must be an existing room')
  
  local roomA = self.rooms[a.id]
  local roomB = self.rooms[b.id]
  local doorA = nil
  local doorB = nil
  
  -- There must be a matching set of unlocked doors between the two rooms
  for key, door in pairs(roomA.doors) do
    if door.destination == b and not door.locked then
      doorA = door
    end
  end
  for key, door in pairs(roomB.doors) do
    if door.destination == a and not door.locked then
      doorB = door
    end
  end
  
  if doorA == nil then
    print('doorA is nil')
    return {}
  end
  if doorB == nil then
    print('doorB is nil')
    return {}
  end
  
  local path = {}
  table.insert(path, doorA.center)
  table.insert(path, doorB.center)
  table.insert(path, roomB.center)
  
  print('Found path:')
  for i, node in ipairs(path) do
    print(node)
  end
  
  return path
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

  assert(instanceOf(Room, room), 'couldn\'t make a valid room')
  
  self.currentRoom = room
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