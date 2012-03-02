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
  
  local startingRoom = Room(1, 1, vector(0, 0), self.roomSize)
  
  self.rooms[startingRoom.id] = startingRoom
  self.currentRoom = startingRoom
end

function Dungeon:idForLevelAndIndex(level, index)
  return ((level - 1) * level / 2) + index	
end

function Dungeon:positionForRoomAtLevelAndIndex(level, index)
  return vector((-level * self.roomSize.x / 2) + (self.roomSize.x / 2) + (self.roomSize.x * index) - self.roomSize.x,
                level * self.roomSize.y - self.roomSize.y)
end

function Dungeon:goToLevelAndIndexFromRoom(level, index, room)
  local destinationRoom = self.rooms[self:idForLevelAndIndex(level, index)]
  
  if destinationRoom == nil then
    local destinationPosition = self:positionForRoomAtLevelAndIndex(destinationLevel, destinationIndex)
    destinationRoom = Room(destinationLevel, destinationIndex, destinationPosition, self.roomSize)
    self.rooms[destinationRoom:getId()] = destinationRoom 
    print('Created new room')
    
  else
    print('Found existing room')
  end
  print(destinationRoom)
  
  assert(destinationRoom ~= nil, 'couldn\'t make a valid room')
  
  self.currentRoom = destinationRoom
end

-- Location: lr, ur, ll, lr, room is a Room() object
function Dungeon:goToLocationFromRoom(location, room)
  local valid_locations = {'ul', 'ur', 'll', 'lr'}
  assert(in_table(location, valid_locations), string.format('invalid location: %s', location))
  
  -- local destinationId = nil
  local destinationLevel = nil
  local destinationIndex = nil

  if location == 'ul' then
    destinationLevel = room.level - 1
    if destinationLevel < 1 then
      assert(false, 'cant go any higher than 1')
      return nil
    end
    
    destinationIndex = room.index - 1
    if destinationIndex < 1 then
      assert(false, 'cant go upper left here')
      return nil
    end
    
  elseif location == 'ur' then
    destinationLevel = room.level - 1
    if destinationLevel < 1 then
      assert(false, 'cant go up here')
      return nil
    end
    
    destinationIndex = room.index
    if destinationIndex > destinationLevel then
      assert(false, 'cant go upper right here')
      return nil
    end
    
  elseif location == 'll' then
    destinationLevel = room.level + 1
    destinationIndex = room.index
  
  elseif location == 'lr' then
    destinationLevel = room.level + 1
    destinationIndex = room.index + 1
  end
  
  self:goToLevelAndIndexFromRoom(destinationLevel, destinationIndex, room)
end

function Dungeon:update(dt)
  local neighbors = self:getNeighborsForRoom(self.currentRoom)
  for index, room in pairs(neighbors) do
    room:update(dt)
  end
  self.currentRoom:draw(dt)
end

function Dungeon:getNeighborsForRoom(room)
  local neighbors = {}
  local level = nil
  local index = nil
  local id = nil
  
  -- Upper left
  level = room.level - 1
  index = room.index - 1
  id = self:idForLevelAndIndex(level, index)
  if self.rooms[id] ~= nil then
    table.insert(neighbors, self.rooms[id])
  end

  -- Upper right
  level = room.level - 1
  index = room.index
  id = self:idForLevelAndIndex(level, index)
  if self.rooms[id] ~= nil then
    table.insert(neighbors, self.rooms[id])
  end
  
  -- left
  level = room.level
  index = room.index - 1
  id = self:idForLevelAndIndex(level, index)
  if self.rooms[id] ~= nil then
    table.insert(neighbors, self.rooms[id])
  end
  
  -- right
  level = room.level
  index = room.index + 1
  id = self:idForLevelAndIndex(level, index)
  if self.rooms[id] ~= nil then
    table.insert(neighbors, self.rooms[id])
  end
  
  -- lower left
  level = room.level + 1
  index = room.index
  id = self:idForLevelAndIndex(level, index)
  if self.rooms[id] ~= nil then
    table.insert(neighbors, self.rooms[id])
  end
  
  -- lower right
  level = room.level + 1
  index = room.index + 1
  id = self:idForLevelAndIndex(level, index)
  if self.rooms[id] ~= nil then
    table.insert(neighbors, self.rooms[id])
  end
  
  return neighbors
end

function Dungeon:draw()
  local level = self.currentRoom.level

  local neighbors = self:getNeighborsForRoom(self.currentRoom)
  for index, room in pairs(neighbors) do
    room:draw()
  end
  self.currentRoom:draw()
end