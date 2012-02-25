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
  self.roomSize = vector(600, 250)
  
  local startingRoom = Room(1, 1)
  startingRoom.size = self.roomSize
  
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

-- Location: lr, ur, ll, lr, room is a Room() object
function Dungeon:goToLocationFromRoom(location, room)
  local valid_locations = {'ul', 'ur', 'll', 'lr'}
  assert(in_table(location, valid_locations), string.format('invalid location: %s', location))
  
  local destinationId = nil
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
  
  local destinationRoom = self.rooms[self:idForLevelAndIndex(destinationLevel, destinationIndex)]
  
  if destinationRoom == nil then
    destinationRoom = Room(destinationLevel, destinationIndex)
    destinationRoom.position = self:positionForRoomAtLevelAndIndex(destinationLevel, destinationIndex)
    destinationRoom.size = room.size
    self.rooms[destinationRoom:getId()] = destinationRoom 
    print('Created new room')
    
  else
    print('Found existing room')
  end
  print(destinationRoom)
  
  assert(destinationRoom ~= nil, 'couldn\'t make a valid room')
  
  
  self.currentRoom = destinationRoom
end

function Dungeon:update(dt)
  self.currentRoom:update(dt)
end

-- function Dungeon:draw

function Dungeon:draw()
  local level = self.currentRoom.level

  for index, room in pairs(self.rooms) do
    room:draw()
  end
  
  -- Draw all rooms at this level, the level above and the level below
  -- for curLevel = level - 1, level + 1 do
  --   for index = 1, curLevel do
  --     local id = self:idForLevelAndIndex(level, index)
  --     if self.rooms[id] ~= nil then
  --       self.rooms[id]:draw()
  --     end
  --   end
  -- end
end