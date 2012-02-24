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

RoomBuilderClass = class('RoomBuilderClass')

function RoomBuilderClass:initialize()
  self.totalRooms = 0
  self.roomSize = vector(600, 250)
  self.roomPadding = 10
end

function RoomBuilderClass:roomWithLevel(level)
  assert(type(level) == 'number', string.format('roomWithLevel expects a number, got: %s', type(level)))

  local room = Room()
  room.id = self.totalRooms
  self.totalRooms = self.totalRooms + 1
  
  room.size = self.roomSize
  room.level = level
  room.color = room.color:random()
  
  return room
end

function RoomBuilderClass:startingRoom()
  return self:roomWithLevel(0)
end

RoomBuilder = RoomBuilderClass()

Room = class('Room')

function Room:initialize()
  self.position = vector(0, 0)
  self.size = vector(0, 0)
  self.location = nil -- 'left' or 'right

  self.parents = {}
  self.parents['left'] = nil
  self.parents['right'] = nil
  
  self.children = {}
  self.children['left'] = nil
  self.children['right'] = nil
  
  self.level = 1
  
  self.color = colors.white
end

function Room:getSibling(location)
  assert(location == 'left' or location == 'right', 'Invalid location')

  if self.parents[location] == nil then
    return nil
  end

  return self.parents[location].children[self:oppositeLocation(self.location)]
end

function Room:oppositeLocation(location)
  assert(location == 'left' or location == 'right', 'Invalid location')
  if location == 'left' then
    return 'right'
  else
    return 'left'
  end
end

function Room:addChild(location)
  assert(location == 'left' or location == 'right', 'Invalid location')

  -- Check to see if there's already a room where we want it
  local sibling = self:getSibling(location)
  if sibling ~= nil then
    local room = sibling.children[self:oppositeLocation(location)]
    if room ~= nil then
      -- Room found, add us to the parents and return
      room.parents[self:oppositeLocation(location)] = self
      return room
    end
  end
  -- Otherwise, create a new room there
  room = RoomBuilder:roomWithLevel(self.level + 1)
  room.parents[self:oppositeLocation(location)] = self
  room.location = location
  
  local pos = self.position:clone()
  pos.y = pos.y + self.size.y + RoomBuilder.roomPadding
  
  if location == 'left' then
    pos.x = pos.x - room.size.x / 2
  else -- right
    pos.x = pos.x + room.size.x / 2
  end

  room.position = pos

  self.children[location] = room
  
  return room
  
end


function Room:update(dt)
end


function Room:draw()
  self.color:set()
  love.graphics.rectangle('line', self.position.x, self.position.y, self.size.x, self.size.y)
  
  if debug then
    love.graphics.print(string.format('id: %s level: %s', self.id, self.level), 
                        self.position.x + 10, 
                        self.position.y + 10);

    local leftParentId = 'nil'
    if self.parents['left'] then
      leftParentId = self.parents['left'].id
    end
    local rightParentId = 'nil'
    if self.parents['right'] then
      rightParentId = self.parents['right'].id
    end

    local leftChildId = 'nil'
    if self.children['left'] then
      leftChildId = self.children['left'].id
    end
    local rightChildId = 'nil'
    if self.children['right'] then
      rightChildId = self.children['right'].id
    end
    
    love.graphics.print(string.format('parents - left: %s right: %s', leftParentId, rightParentId),
                        self.position.x + 10, 
                        self.position.y + 30);

    love.graphics.print(string.format('children - left: %s right: %s', leftChildId, rightChildId), 
                        self.position.x + 10, 
                        self.position.y + 40);

  end
end

